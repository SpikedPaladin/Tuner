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

                return new ScaleRow() {
                    title = title,
                    subtitle = subtitle,
                    draw_value = draw_value,
                    digits = digits,
                    adjustment = adjustment
                }.build(binding);
            }

            return null;
        }
    }
}
