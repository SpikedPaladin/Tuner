namespace Tuner {

    public class SearchablePanelList : PanelList {
        private ListStore _search_model;
        private Gtk.ListBox list_box;
        private Gtk.SearchBar search_bar;
        private Gtk.SearchEntry search_entry;

        public unowned ListStore? search_model {
            get { return _search_model; }
            set {
                if (value == null) {
                    list_box.bind_model(null, null);
                    return;
                }

                if (value.get_item_type().is_a(typeof(Item))) {
                    _search_model = value;
                    list_box.bind_model(_search_model, create_row);
                }
            }
        }

        construct {
            stack.add_named(list_box = new Gtk.ListBox() {
                css_classes = { "navigation-sidebar" },
                selection_mode = Gtk.SelectionMode.NONE
            }, "search");
            list_box.row_activated.connect(activated);
            search_model = new ListStore(typeof(Item));
            var button = new Gtk.ToggleButton() {
                css_classes = { "flat" },
                child = new Gtk.Image.from_icon_name("edit-find-symbolic")
            };
            pack_start(button);

            search_bar = new Gtk.SearchBar();
            search_bar.bind_property("search-mode-enabled", button, "active", BindingFlags.BIDIRECTIONAL);
            search_entry = new Gtk.SearchEntry() {
                hexpand = true
            };
            search_bar.child = search_entry;
            search_entry.search_changed.connect(() => {
                if (search_entry.text.length > 0) {
                    stack.visible_child_name = "search";
                    update_search(search_entry.text);
                } else {
                    stack.visible_child_name = "main";
                    update_search(null);
                }
            });

            add_top_bar(search_bar);
        }

        public void clear() {
            search_model.remove_all();
        }

        private Gtk.Widget create_row(Object obj) {
            var item = (Item) obj;
            return new PanelListRow.with_item(item);
        }

        private void activated(Object obj) {
            search_bar.search_mode_enabled = false;
            search_result_activated(((PanelListRow) obj).item);
        }

        public signal void update_search(string? text);
        public signal void search_result_activated(Item item);
    }
}
