using Gee;

namespace Tuner.CacheUtil {
    private TreeMap<Page, Panel> panel_cache;
    private TreeMap<Page, PanelList> list_cache;

    public PanelList? get_list(Page page, out bool created) {
        ensure_cache();

        created = false;

        if (page.has_subpages) {
            var list = list_cache.get(page);

            if (list == null) {
                list = new PanelList(page);
                created = true;
            }

            return list;
        }

        return null;
    }

    public Panel? get_panel(Page page) {
        ensure_cache();

        if (!page.has_subpages) {
            var panel = panel_cache.get(page);

            if (panel == null) {
                panel = new Panel.with_page(page);
                panel_cache.set(page, panel);
            }

            return panel;
        }

        return null;
    }

    private void ensure_cache() {
        if (panel_cache == null)
            panel_cache = new TreeMap<Page, Panel>();

        if (list_cache == null)
            list_cache = new TreeMap<Page, PanelList>();
    }
}
