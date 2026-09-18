namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-list-row.ui")]
    public class PanelListRow : Adw.PreferencesRow {
        public Item item { get; set; }
        public Page page { get; set; }
        public string icon_name { get; set; }
        public string description { get; set; }
        public bool show_description { get; set; }
        public bool show_next_icon { get; set; }

        public Panel panel { get; set; }

        public PanelListRow.with_item(Item item) {
            this.item = item;

            if (item is Page) {
                var page = (Page) item;

                title = page.title;
                icon_name = page.icon_name;

                if (page.parent != null)
                    description = SearchUtil.build_path(page);
                else
                    description = page.description;
            } else {
                var widget = (Widget) item;

                title = SearchUtil.extract_title(widget);
                description = SearchUtil.build_path(widget);
                icon_name = SearchUtil.get_page_icon(widget);
            }

            if (description != null && description != "")
                show_description = true;
        }

        public PanelListRow(Page page, bool show_description = false) {
            this.page = page;

            page.bind_property("title", this, "title", BindingFlags.SYNC_CREATE);
            page.bind_property("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);

            if (page.description != null && page.description != "") {
                this.show_description = show_description;
                page.bind_property("description", this, "description", BindingFlags.SYNC_CREATE);
            }

            if (page.has_subpages || page.list != null)
                show_next_icon = true;

            if (!page.has_subpages)
                panel = CacheUtil.get_panel(page);
        }
    }
}
