import frappe

@frappe.whitelist()
def get_dashboard_data(filters=None):
    return {
        "overdue_invoices": 12,
        "draft_entries": 4,
        "pending_bank_items": 7,
    }