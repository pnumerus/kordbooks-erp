frappe.pages["staff-dashboard"].on_page_load = function (wrapper) {
  var page = frappe.ui.make_app_page({
    parent: wrapper,
    title: "Staff Dashboard",
    single_column: true
  });

  page.set_primary_action("Refresh", function () {
    load_dashboard(page, wrapper);
  });

  page.add_field({
    label: "Company",
    fieldname: "company",
    fieldtype: "Link",
    options: "Company",
    change: function () {
      load_dashboard(page, wrapper);
    }
  });

  var $main = $(wrapper).find(".layout-main-section");

  $main.html(
    '<div class="kordbooks-staff-dashboard">' +
      '<div class="dashboard-main-actions" style="margin-bottom: 16px;">' +
        '<button class="btn btn-primary" id="sales-invoices-link">Sales Invoices</button>' +
      '</div>' +
      '<div id="dashboard-kpis"></div>' +
      '<div id="dashboard-worklists"></div>' +
    '</div>'
  );

  $main.find("#sales-invoices-link").on("click", function () {
    frappe.set_route("List", "Sales Invoice");
  });

  load_dashboard(page, wrapper);
};

function load_dashboard(page, wrapper) {
  var filters = page.get_form_values();
  var $main = $(wrapper).find(".layout-main-section");

  frappe.call({
    method: "kordbooks_erp.kordbooks_practice.page.staff_dashboard.staff_dashboard.get_dashboard_data",
    args: { filters: filters },
    // callback: function (r) {
    //   var data = r.message || {};
    //   $main.find("#dashboard-kpis").html(
    //     "<pre>" + JSON.stringify(data, null, 2) + "</pre>"
    //   );
    // }
  });
}