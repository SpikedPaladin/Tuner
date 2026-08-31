namespace Tuner {

    public class PluginsDialog : Adw.Dialog {

        construct {
            var group = new Group();
            var engine = Peas.Engine.get_default();
            for (int i = 0; i < engine.get_n_items(); i++) {
                var info = engine.get_item(i) as Peas.PluginInfo;
                group.add(new PluginRow(info));
            }
            var page = new Page();
            group.insert_after(page, null);

            var content = new PanelPage.with_page(page) {
                title = _("Plugins list")
            };
            content.pack_start(new Gtk.Button.from_icon_name("system-reboot-symbolic") {
                tooltip_text = _("Restart app"),
                action_name = "app.restart"
            });
            child = content;
            content_width = 640;
        }
    }

    public class PluginRow : Widget {
        private Peas.PluginInfo info;

        public PluginRow(Peas.PluginInfo info) {
            this.info = info;
            binding = new Setting() {
                schema_id = "org.altlinux.Tuner",
                schema_key = "disabled-plugins",
                transform = new FlagsTransform() {
                    value = info.module_name,
                    inverse = true
                }
            };
        }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new Adw.ExpanderRow() {
                    title = info.name
                };
                var switch = new Gtk.Switch() {
                    valign = Gtk.Align.CENTER
                };
                row.add_suffix(switch);

                row.add_row(new Gtk.ListBoxRow() {
                    activatable = false,
                    focusable = false,
                    child = build_expanded_row()
                });

                binding.bind(switch, "active");

                return row;
            }
            return null;
        }

        private Gtk.Widget? build_expanded_row() {
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.START
            };
            box.add_css_class("header");
            var has_ui = false;

            if (info.copyright != null) {
                has_ui = true;
                box.append(new Gtk.Label(info.copyright) {
                    halign = Gtk.Align.START
                });
            }

            var grid = new Gtk.Grid() {
                valign = Gtk.Align.CENTER,
                column_spacing = 12,
                row_spacing = 4,
                margin_top = 6,
                margin_bottom = 6,
                margin_end = 6,
                margin_start = 6,
                vexpand = true
            };
            var has_grid = false;
            if (info.authors.length > 0) {
                has_grid = has_ui = true;
                var authors = info.authors[0];

                for (int i = 1; i < info.authors.length; i++)
                    authors += @", $(info.authors[i])";

                put_to_grid(grid, _("Authors"), authors, 0);
            }
            if (info.version != null) {
                has_grid = has_ui = true;
                put_to_grid(grid, _("Version"), info.version, 1);
            }
            if (info.website != null) {
                has_grid = has_ui = true;
                put_to_grid(grid, _("Website"), @"<a href=\"$(info.website)\">$(info.website)</a>", 2);
            }

            if (has_grid)
                box.append(grid);

            if (has_ui)
                return box;

            box.append(new Gtk.Label(_("Plugin information not found.")) {
                halign = Gtk.Align.START,
                vexpand = true
            });
            return box;
        }

        private void put_to_grid(Gtk.Grid grid, string label1, string label2, int row) {
            var label = new Gtk.Label(label1) {
                css_classes = { "dimmed" },
                halign = Gtk.Align.END
            };
            grid.attach(label, 0, row, 1, 1);
            grid.attach_next_to(new Gtk.Label(label2) {
                halign = Gtk.Align.START,
                use_markup = true,
                wrap = true,
            }, label, Gtk.PositionType.RIGHT, 1, 1);
        }
    }
}
