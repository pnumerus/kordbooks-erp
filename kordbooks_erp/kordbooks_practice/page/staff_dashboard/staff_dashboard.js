frappe.pages["staff-dashboard"].on_page_load = function (wrapper) {
  const page = frappe.ui.make_app_page({
    parent: wrapper,
    title: "Staff Dashboard",
    single_column: true,
  });

  page.set_primary_action("Refresh", () => load_dashboard(page));

  page.add_inner_button("Sales Invoices", () => {
    frappe.set_route("List", "Sales Invoice");
  });

  page.add_field({
    label: "Company",
    fieldname: "company",
    fieldtype: "Link",
    options: "Company",
    change() {
      load_dashboard(page);
    },
  });

  page.main.innerHTML = `
    <div class="kordbooks-staff-dashboard">
      <div id="dashboard-kpis"></div>
      <div id="dashboard-worklists"></div>
    </div>
  `;

  load_dashboard(page);
};

function load_dashboard(page) {
  const filters = page.get_form_values();

  frappe.call({
    method: "kordbooks_erp.kordbooks_practice.page.staff_dashboard.staff_dashboard.get_dashboard_data",
    args: { filters },
    callback: function (r) {
      const data = r.message || {};
      document.getElementById("dashboard-kpis").innerHTML = `
        <pre>${JSON.stringify(data, null, 2)}</pre>
      `;
    },
  });
}