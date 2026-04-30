# This code is not a new DocType. It is backend Python code for your custom page, and its job is to create a standard ERPNext Sales Invoice doctype by using Frappe’s Document API

import frappe
from frappe.utils import flt, getdate


DEFAULT_CUSTOMER = "Retail Sales Customer"

SHORTCUTS = {
	"food": {
		"item_code": "FOOD-SALES",
		"description": "Food Sales",
	},
	"drinks": {
		"item_code": "DRINKS-SALES",
		"description": "Drink Sales",
	},
	"accommodation": {
		"item_code": "ROOM-SALES",
		"description": "Accommodation Sales",
	},
	"service_charge": {
		"item_code": "SERVICE-CHARGE",
		"description": "Service Charge",
	},
	"general": {
		"item_code": "GENERAL-SALES",
		"description": "General Sales",
	},
}

VAT_TEMPLATES = {
	"no_vat": None,
	"vat_20": "UK VAT 20%",
}


def _validate_payload(data):
	if not data.get("company"):
		frappe.throw("Company is required")

	if not data.get("invoice_date"):
		frappe.throw("Invoice Date is required")

	if flt(data.get("amount")) <= 0:
		frappe.throw("Amount must be greater than zero")

	if data.get("shortcut") not in SHORTCUTS:
		frappe.throw("Invalid shortcut selected")

	if not frappe.db.exists("Customer", DEFAULT_CUSTOMER):
		frappe.throw(
			f"Default customer '{DEFAULT_CUSTOMER}' does not exist. Create it first."
		)

	item_code = SHORTCUTS[data.get("shortcut")]["item_code"]
	if not frappe.db.exists("Item", item_code):
		frappe.throw(f"Item '{item_code}' does not exist. Create it first.")


@frappe.whitelist()
def create_sales_invoice(data, submit_after_insert=0):
	data = frappe.parse_json(data)
	_validate_payload(data)

	shortcut = SHORTCUTS[data.get("shortcut")]
	tax_template = VAT_TEMPLATES.get(data.get("vat_mode"))

	doc = frappe.get_doc(
		{
			"doctype": "Sales Invoice",
			"company": data.get("company"),
			"customer": DEFAULT_CUSTOMER,
			"posting_date": getdate(data.get("invoice_date")),
			"due_date": getdate(data.get("payment_date") or data.get("invoice_date")),
			"taxes_and_charges": tax_template,
			"kordbooks_invoice_number": data.get("invoice_number"),
			"kordbooks_payment_date": getdate(data.get("payment_date"))
			if data.get("payment_date")
			else None,
			"kordbooks_shortcut": data.get("shortcut"),
			"kordbooks_notes": data.get("notes"),
			"items": [
				{
					"item_code": shortcut["item_code"],
					"description": shortcut["description"],
					"qty": 1,
					"rate": flt(data.get("amount")),
				}
			],
		}
	)

	doc.insert()

	if int(submit_after_insert):
		doc.submit()

	return {
		"name": doc.name,
		"docstatus": doc.docstatus,
	}