module menu;
import std;
import raylib;
import config;
import client;

enum UIComponentType {
    LABEL,
    BUTTON,
    ENTRY,
}

abstract class UIComponent {
    UIComponentType type;
    Rectangle rect, off_rect;
    Color color;
    bool is_selected = false;
    Font *font = null;
    string text = null;
    void delegate(UIComponent) onClick = null;

    this(UIComponentType uitype, Rectangle shape, Color col) {
        type = uitype;
        rect = off_rect = shape;
        color = col;
    }

    bool selected() {
        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
            is_selected = (CheckCollisionPointRec(GetMousePosition(), rect));
            if (is_selected && this.onClick !is null) this.onClick(this);
        }
        return is_selected;
    }

    void update() {}

    void render() {
        DrawRectangleRec(rect, color);
        DrawRectangleLines(rect.x.to!int, rect.y.to!int, rect.width.to!int, rect.height.to!int, COLOR_BORDER);
        if (text !is null && font !is null) {
            immutable size = MeasureTextEx(*font, text.toStringz, FONT_SIZE, FONT_SPACING);
            immutable pos = Vector2(rect.x+(rect.width/2)-(size.x/2), rect.y+(rect.height/2)-(size.y/2));
            DrawTextEx(*font, text.toStringz, pos, FONT_SIZE, FONT_SPACING, COLOR_TEXT);
        }
    }
}

enum LabelAlignment {
    LEFT,
    CENTER,
    RIGHT,
}

class Label : UIComponent {
    LabelAlignment alignment;

    this(Vector2 lbl_pos, LabelAlignment lbl_alignment, string lbl_text) {
        super(UIComponentType.LABEL, Rectangle(lbl_pos.x, lbl_pos.y, 0, 0), COLOR_TEXT);
        alignment = lbl_alignment;
        text = lbl_text;
    }

    override bool selected() {
        immutable size = MeasureTextEx(*font, text.toStringz, FONT_SIZE, FONT_SPACING);
        rect.width = size.x;
        rect.height = size.y;
        return super.selected();
    }

    override void render() {
        immutable size = MeasureTextEx(*font, text.toStringz, FONT_SIZE, FONT_SPACING);
        Vector2 pos;
        final switch (alignment) {
        case LabelAlignment.LEFT:
            pos = Vector2(rect.x, rect.y);
            break;
        case LabelAlignment.CENTER:
            pos = Vector2(rect.x - size.x/2, rect.y);
            break;
        case LabelAlignment.RIGHT:
            pos = Vector2(rect.x - size.x, rect.y);
            break;
        }
        if (text !is null && font !is null) {
            DrawTextEx(*font, text.toStringz, pos, FONT_SIZE, FONT_SPACING, COLOR_TEXT);
        }
    }
}

class Button : UIComponent {
    this(Rectangle rect, string btn_text, void delegate(UIComponent) on_click) {
        super(UIComponentType.BUTTON, rect, COLOR_BUTTON);
        text = btn_text;
        onClick = on_click;
    }

    override void update() {
        is_selected = false;
    }
}

class Entry : UIComponent {
    void delegate(UIComponent) onFinish;
    ulong text_pos;

    this(Rectangle rect, string ent_text, void delegate(UIComponent) on_finish) {
        super(UIComponentType.ENTRY, rect, COLOR_ENTRY);
        text = ent_text;
        text_pos = text.length;
        onFinish = on_finish;
    }

    override void update() {
        immutable chr = GetCharPressed();
        if (!chr) {
            immutable key = GetKeyPressed();
            switch (key) {
            case KEY_ENTER:
                if (this.onFinish !is null) this.onFinish(this);
                text_pos = text.length;
                is_selected = false;
                break;
            case KEY_LEFT:
                if (text_pos) --text_pos;
                break;
            case KEY_RIGHT:
                if (text_pos < text.length) ++text_pos;
                break;
            case KEY_BACKSPACE:
                if (text_pos) {
                    text = text[0..text_pos-1] ~ text[text_pos..$];
                    --text_pos;
                }
                break;
            case KEY_DELETE:
                if (text_pos < text.length) {
                    text = text[0..text_pos] ~ text[text_pos+1..$];
                }
                break;
            case KEY_HOME:
                text_pos = 0;
                break;
            case KEY_END:
                text_pos = text.length;
                break;
            default: break;
            }
        } else {
            text = text[0..text_pos] ~ cast(char)(chr) ~ text[text_pos..$];
            ++text_pos;
        }
    }

    override void render() {
        DrawRectangleRec(rect, color);
        DrawRectangleLines(rect.x.to!int, rect.y.to!int, rect.width.to!int, rect.height.to!int, COLOR_BORDER);

        if (text !is null && font !is null) {
            immutable size = MeasureTextEx(*font, text.toStringz, FONT_SIZE, FONT_SPACING);
            immutable pos = Vector2(rect.x+5, rect.y+(rect.height/2)-(size.y/2));
            DrawTextEx(*font, text.toStringz, pos, FONT_SIZE, FONT_SPACING, COLOR_TEXT);
            immutable cursor_pos = MeasureTextEx(*font, text[0..text_pos].toStringz, FONT_SIZE, FONT_SPACING);
            immutable cursor_x = to!int(pos.x+cursor_pos.x+FONT_SPACING);
            DrawLine(cursor_x, to!int(pos.y), cursor_x, to!int(pos.y+size.y), COLOR_TEXT);
        } else {
            immutable pos = Vector2(rect.x+5, rect.y+(rect.height/2)-(FONT_SIZE/2));
            DrawLine(to!int(pos.x), to!int(pos.y), to!int(pos.x), to!int(pos.y+FONT_SIZE), COLOR_TEXT);
        }
    }
}

class Menu {
    Rectangle rect;
    Font font;
    int scroll_y = 0;
    UIComponent[] components;

    this(Rectangle shape) {
        rect = shape;
        font = LoadFontEx(FONT_PATH.toStringz, FONT_SIZE, null, FONT_CODEPOINTS);
    }

    void addComponent(UIComponent component) {
        component.font = &font;
        component.rect.x = component.off_rect.x + rect.x;
        component.rect.y = component.off_rect.y + rect.y;
        components ~= component;
    }

    void render() {
        DrawRectangleRec(rect, COLOR_WINDOW);
        DrawRectangleLines(rect.x.to!int, rect.y.to!int, rect.width.to!int, rect.height.to!int, COLOR_BORDER);

        if (components.length > 0) {
            auto first = &components[0];
            auto last = &components[$-1];
            auto wheel = GetMouseWheelMove();
            if (wheel > 0 && first.rect.y < rect.y) scroll_y += (wheel*SCROLL_SPEED).to!int;
            else if (wheel < 0 && last.rect.y+last.rect.height > rect.y+rect.height) scroll_y += (wheel*SCROLL_SPEED).to!int;
        }

        foreach (component; components) {
            component.rect.x = component.off_rect.x + rect.x;
            component.rect.y = scroll_y + component.off_rect.y + rect.y;
            if (component.rect.y < rect.y || component.rect.y+component.rect.height > rect.y+rect.height)
                continue;
            component.render();
            if (component.selected())
                component.update();
        }
    }
}

