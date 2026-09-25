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
    int font_size = FONT_SIZE, font_spacing = FONT_SPACING;
    Font *font = null;
    string text = null;
    void delegate(UIComponent) onClick = null;

    this(UIComponentType uitype, Rectangle shape, Color col) {
        type = uitype;
        rect = off_rect = shape;
        color = col;
    }

    bool selected() {
        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
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
            immutable size = MeasureTextEx(*font, text.toStringz, font_size, font_spacing);
            immutable pos = Vector2(rect.x+(rect.width/2)-(size.x/2), rect.y+(rect.height/2)-(size.y/2));
            DrawTextEx(*font, text.toStringz, pos, font_size, font_spacing, COLOR_TEXT);
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
        immutable size = MeasureTextEx(*font, text.toStringz, font_size, font_spacing);
        rect.width = size.x;
        rect.height = size.y;
        return super.selected();
    }

    override void render() {
        immutable size = MeasureTextEx(*font, text.toStringz, font_size, font_spacing);
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
            DrawTextEx(*font, text.toStringz, pos, font_size, font_spacing, COLOR_TEXT);
        }
    }

    ulong getWrappingPoint(float bound) {
        auto pos = text.length+1;
        Vector2 size;
        do {
            --pos;
            size = MeasureTextEx(*font, text[0..pos].toStringz, font_size, font_spacing);
        } while (size.x > bound);
        return pos;
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
            case KeyboardKey.KEY_ENTER:
                if (this.onFinish !is null) this.onFinish(this);
                text_pos = text.length;
                is_selected = false;
                break;
            case KeyboardKey.KEY_LEFT:
                if (text_pos) --text_pos;
                break;
            case KeyboardKey.KEY_RIGHT:
                if (text_pos < text.length) ++text_pos;
                break;
            case KeyboardKey.KEY_BACKSPACE:
                if (text_pos) {
                    text = text[0..text_pos-1] ~ text[text_pos..$];
                    --text_pos;
                }
                break;
            case KeyboardKey.KEY_DELETE:
                if (text_pos < text.length) {
                    text = text[0..text_pos] ~ text[text_pos+1..$];
                }
                break;
            case KeyboardKey.KEY_HOME:
                text_pos = 0;
                break;
            case KeyboardKey.KEY_END:
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
            immutable size = MeasureTextEx(*font, text.toStringz, font_size, font_spacing);
            immutable pos = Vector2(rect.x+5, rect.y+(rect.height/2)-(size.y/2));
            DrawTextEx(*font, text.toStringz, pos, font_size, font_spacing, COLOR_TEXT);
            immutable cursor_pos = MeasureTextEx(*font, text[0..text_pos].toStringz, font_size, font_spacing);
            immutable cursor_x = to!int(pos.x+cursor_pos.x+font_spacing);
            DrawLine(cursor_x, to!int(pos.y), cursor_x, to!int(pos.y+size.y), COLOR_TEXT);
        } else {
            immutable pos = Vector2(rect.x+5, rect.y+(rect.height/2)-(font_size/2));
            DrawLine(to!int(pos.x), to!int(pos.y), to!int(pos.x), to!int(pos.y+font_size), COLOR_TEXT);
        }
    }
}

class Menu {
    Rectangle rect;
    Font font;
    int scroll_y = 0;
    int font_size, font_spacing;
    UIComponent[] components;

    this(Rectangle shape, string path = FONT_PATH, int size = FONT_SIZE, int spacing = FONT_SPACING) {
        rect = shape;
        font_size = size;
        font_spacing = spacing;
        font = LoadFontEx(path.toStringz, font_size, null, FONT_CODEPOINTS);
    }

    void addComponent(UIComponent component) {
        component.font = &font;
        component.font_size = font_size;
        component.font_spacing = font_spacing;
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

