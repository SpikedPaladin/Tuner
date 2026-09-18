using Gee;

namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/main-window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        private ArrayList<Adw.Breakpoint> applied_breakpoints;

        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;
        [GtkChild]
        private unowned Adw.NavigationView nav;
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned Gtk.Button action_button;
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned SearchablePanelList panel_list;
        [GtkChild]
        private unowned Adw.BreakpointBin breakpoint_bin;

        public ListStore model {
            get; set; default = new ListStore(typeof(Page));
        }

        construct {
            applied_breakpoints = new ArrayList<Adw.Breakpoint>();
        }

        public MainWindow(Gtk.Application app) {
            Object(application: app);

            Tuner.init(
                text => {
                    toast(text);
                    return true;
                },
                (page, show) => {
                    set_page(page, show);
                    return true;
                },
                page => {
                    nav.push(page);
                    return true;
                }
            );
        }

        public void load_pages(ArrayList<Page> pages) {
            foreach (var page in pages)
                add_page(page);

            open_last();

            if (pages.is_empty)
                show_all_disabled();
        }

        public bool add_page(Page page) {
            model.insert_sorted(page, (a, b) => ((Page) a).priority - ((Page) b).priority);

            stack.visible_child_name = "content";

            return true;
        }

        public void open_last() {
            var id = App.settings.get_string("last-page");

            if (id != "") {
                for (int i = 0; i < model.n_items; i++) {
                    var page = (Page) model.get_item(i);
                    if (page.id == id) {
                        panel_list.activate_index(i);
                        return;
                    }
                }
            }

            panel_list.activate_index(0);
        }

        public void show_all_disabled() {
            action_button.label = _("Plugins list");
            action_button.action_name = "app.plugin-list";
        }

        public void toast(string title) {
            toast_overlay.add_toast(new Adw.Toast(title) {
                timeout = 3
            });
        }

        private void apply_breakpoints(ArrayList<Adw.Breakpoint>? breakpoints) {
            foreach (var breakpoint in applied_breakpoints)
                breakpoint_bin.remove_breakpoint(breakpoint);

            if (breakpoints != null)
                foreach (var breakpoint in breakpoints)
                    breakpoint_bin.add_breakpoint(breakpoint);
        }

        private void set_page(Adw.NavigationPage? page, bool show = true) {
            split_view.content = page;

            if (show)
                split_view.show_content = true;
        }

        [GtkCallback]
        private void update_search(string? text) {
            if (text != null) {
                panel_list.clear();
                for (int i = 0; i < model.n_items; i++) {
                    var page = (Page) model.get_item(i);
                    if (page.title.down().contains(text.down())) {
                        panel_list.search_model.append(page);
                    }
                    page.visit_children(item => {
                        if (item is Group || item is Page) {
                            if (item is Page) {
                                var child_page = (Page) item;
                                if (child_page.title.down().contains(text.down())) {
                                    panel_list.search_model.append(child_page);
                                }
                            }
                            return VisitResult.RECURSE;
                        }

                        var widget = item as Widget;
                        if (widget != null) {
                            var title = SearchUtil.extract_title(widget);

                            if (title != null && title.down().contains(text.down()))
                                panel_list.search_model.append(widget);
                        }

                        return VisitResult.CONTINUE;
                    });
                }
            }
        }

        [GtkCallback]
        private void search_result_activated(Item result) {
            if (result is Page) {
                var page = (Page) result;

                if (page.parent == null)
                    activate_top_level_page(page);
                else
                    activate_page(page, true);
            } else if (result is Widget) {
                var widget = (Widget) result;
                var page = SearchUtil.get_page(widget);

                if (page != null)
                    activate_page(page, true, widget);
            }
        }

        private void activate_top_level_page(Page page) {
            for (int i = 0; i < model.n_items; i++) {
                if (model.get_item(i) == page) {
                    panel_list.activate_index(i);
                    return;
                }
            }
        }

        private void activate_page(Page page, bool manual, Widget? focus_widget = null) {
            if (page.has_subpages) {
                bool created = false;
                var list = CacheUtil.get_list(page, out created);

                if (created)
                    list.row_activated.connect(row_activated);

                nav.push(list);
                focus_first_leaf(page, list);
                return;
            }

            if (page.list != null)
                nav.push(page.list);

            var panel = CacheUtil.get_panel(page);
            if (panel == null) return;

            show_page(page, panel, manual);

            if (focus_widget?.native_widget != null)
                Timeout.add_once(100, () => focus_widget.native_widget.grab_focus());
        }

        private void focus_first_leaf(Page page, PanelList list) {
            for (int i = 0; i < page.subpages_model.n_items; i++) {
                var subpage = (Page) page.subpages_model.get_item(i);
                if (subpage.has_subpages || subpage.list != null) continue;

                var list_row = list.get_row_at_index(i);
                if (list_row != null) {
                    list_row.grab_focus();
                    activate_row(list_row, false);
                }
                break;
            }
        }

        private void show_page(Page page, Panel panel, bool manual) {
            apply_breakpoints(page.breakpoints);
            set_page(panel, manual);
        }

        [GtkCallback]
        private void row_activated(PanelListRow row) {
            activate_row(row);
        }

        private void activate_row(PanelListRow row, bool manual = true) {
            if (row.page.has_subpages) {
                bool created = false;
                var list = CacheUtil.get_list(row.page, out created);

                if (created)
                    list.row_activated.connect(row_activated);

                nav.push(list);
                focus_first_leaf(row.page, list);
                return;
            }

            if (row.page.list != null)
                nav.push(row.page.list);

            App.settings.set_string("last-page", row.page.id ?? "");
            apply_breakpoints(row.page.breakpoints);
            set_page(row.panel, row.page.list != null ? false : manual);
        }
    }
}
