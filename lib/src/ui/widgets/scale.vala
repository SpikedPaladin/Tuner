namespace Tuner {

    public class Scale : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public bool draw_value { get; set; }
        public int digits { get; set; }
        public Gtk.Scale? marked_scale { get; set; }
        public Gtk.Adjustment? adjustment { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var adjustment = this.adjustment ?? binding.create_adjustment();
                if (adjustment == null)
                    return null;

                var row = new Adw.ActionRow() {
                    title = title,
                    subtitle = subtitle
                };

                var reset_button = new ResetButton() {
                    revealer = Gtk.Align.END
                };
                reset_button.reset.connect(binding.reset);

                if (binding.has_default)
                    binding.bind_property("is-default", reset_button, "reveal", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

                row.add_suffix(reset_button);

                var scale = marked_scale;

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

                row.add_suffix(scale);
                row.activatable_widget = scale;

                binding.bind(adjustment, "value");
                return new ScaleRow() {
                    title = title,
                    subtitle = subtitle,
                    draw_value = draw_value,
                    digits = digits,
                    adjustment = adjustment
                }.build();
            }

            return null;
        }
    }
}
