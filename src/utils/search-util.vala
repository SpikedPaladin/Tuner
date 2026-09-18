namespace Tuner.SearchUtil {

    public string build_path(Item item) {
        var current_parent = item.parent;

        var path = "";
        while (current_parent != null) {
            if (path == "") {
                path = extract_title(current_parent) ?? "";
            } else {
                var title = extract_title(current_parent);

                if (title != null && title != "")
                    path = @"$title -> $path";
            }

            current_parent = current_parent.parent;
        }

        return path;
    }

    public Page? get_page(Widget widget) {
        var current_parent = widget.parent;

        while (current_parent != null) {
            if (current_parent is Page) {
                return (Page) current_parent;
            }
            current_parent = current_parent.parent;
        }

        return null;
    }

    public string get_page_icon(Widget widget) {
        var page = get_page(widget);

        if (page != null)
            return page.icon_name;

        return "";
    }

    public string? extract_title(Item item) {
        var property_name = "title";
        var pspec = item.get_class().find_property(property_name);

        if (pspec != null && pspec.value_type == typeof(string)) {
            var @value = Value(typeof(string));
            item.get_property(property_name, ref @value);

            return @value.get_string();
        }

        return null;
    }
}
