namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/scale-row.ui")]
    public class ScaleRow : Adw.PreferencesRow {
        private Gtk.Scale scale;

        [GtkChild]
        private unowned ResetButton reset_button;
        [GtkChild]
        private unowned Adw.Breakpoint breakpoint;
        [GtkChild]
        private unowned Gtk.Box box;
        [GtkChild]
        private unowned Adw.ActionRow action_row;

        public string subtitle { get; set; }
        public bool draw_value { get; set; }
        public int digits { get; set; }
        public Gtk.Scale? marked_scale { get; set; }
        public Gtk.Adjustment? adjustment { get; set; }

        public ScaleRow build(Binding binding) {
            breakpoint.apply.connect(move_down);
            breakpoint.unapply.connect(move_up);

            binding.bind(adjustment, "value");

            reset_button.reset.connect(binding.reset);

            if (binding.has_default)
                binding.bind_property("is-default", reset_button, "reveal", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

            scale = marked_scale;

            if (scale == null) {
                scale = new Gtk.Scale(Gtk.Orientation.HORIZONTAL, adjustment) {
                    draw_value = draw_value,
                    width_request = 140,
                    hexpand = true,
                    digits = digits
                };
            } else {
                scale.adjustment = this.adjustment ?? adjustment;
                scale.orientation = Gtk.Orientation.HORIZONTAL;
                scale.hexpand = true;
                scale.draw_value = draw_value;
                scale.width_request = 140;
                scale.digits = digits;
            }

            move_up();

            return this;
        }

        private void move_down() {
            action_row.remove(scale);

            box.append(scale);
        }

        private void move_up() {
            if (scale.parent != null)
                box.remove(scale);

            action_row.add_suffix(scale);
        }
    }
}
