frappe.pages["sales-invoice-entry"].on_page_load = function (wrapper) {
	let page = frappe.ui.make_app_page({
		parent: wrapper,
		title: "Sales Invoice Entry",
		single_column: true,
	});

	let $main = $(wrapper).find(".layout-main-section");

	$main.html(`
		<div class="kordbooks-sales-entry" style="padding: 16px; max-width: 760px;">
			<h3 style="margin-bottom: 16px;">Sales Invoice Entry</h3>

			<div class="row" style="margin-bottom: 12px;">
				<div class="col-sm-6">
					<label class="control-label">Company</label>
					<input type="text" id="company" class="form-control" placeholder="Company name">
				</div>
				<div class="col-sm-6">
					<label class="control-label">Invoice Number</label>
					<input type="text" id="invoice_number" class="form-control" placeholder="External invoice number">
				</div>
			</div>

			<div class="row" style="margin-bottom: 12px;">
				<div class="col-sm-4">
					<label class="control-label">Invoice Date</label>
					<input type="date" id="invoice_date" class="form-control">
				</div>
				<div class="col-sm-4">
					<label class="control-label">Payment Date</label>
					<input type="date" id="payment_date" class="form-control">
				</div>
				<div class="col-sm-4">
					<label class="control-label">Amount</label>
					<input type="number" step="0.01" id="amount" class="form-control" placeholder="0.00">
				</div>
			</div>

			<div class="row" style="margin-bottom: 12px;">
				<div class="col-sm-6">
					<label class="control-label">Shortcut</label>
					<select id="shortcut" class="form-control">
						<option value="food">Food Sales</option>
						<option value="drinks">Drink Sales</option>
						<option value="accommodation">Accommodation</option>
						<option value="service_charge">Service Charge</option>
						<option value="general">General Sales</option>
					</select>
				</div>
				<div class="col-sm-6">
					<label class="control-label">VAT Mode</label>
					<select id="vat_mode" class="form-control">
						<option value="no_vat">No VAT</option>
						<option value="vat_20">VAT 20%</option>
					</select>
				</div>
			</div>

			<div style="margin-bottom: 16px;">
				<label class="control-label">Notes</label>
				<textarea id="notes" class="form-control" rows="3" placeholder="Optional notes"></textarea>
			</div>

			<div style="display: flex; gap: 8px;">
				<button class="btn btn-primary" id="save-draft">Save Draft</button>
				<button class="btn btn-default" id="save-submit">Save & Submit</button>
			</div>
		</div>
	`);

	function collect_data() {
		return {
			company: $main.find("#company").val(),
			invoice_number: $main.find("#invoice_number").val(),
			invoice_date: $main.find("#invoice_date").val(),
			payment_date: $main.find("#payment_date").val(),
			amount: $main.find("#amount").val(),
			shortcut: $main.find("#shortcut").val(),
			vat_mode: $main.find("#vat_mode").val(),
			notes: $main.find("#notes").val(),
		};
	}

	function save_invoice(submit_after_insert) {
		frappe.call({
			method: "kordbooks_erp.kordbooks_practice.page.sales_invoice_entry.sales_invoice_entry.create_sales_invoice",
			args: {
				data: collect_data(),
				submit_after_insert: submit_after_insert ? 1 : 0,
			},
			freeze: true,
			freeze_message: "Creating Sales Invoice...",
			callback: function (r) {
				if (!r.message) return;

				frappe.msgprint(`Created Sales Invoice: ${r.message.name}`);

				if (r.message.name) {
					frappe.set_route("Form", "Sales Invoice", r.message.name);
				}
			},
		});
	}

	$main.find("#save-draft").on("click", function () {
		save_invoice(false);
	});

	$main.find("#save-submit").on("click", function () {
		save_invoice(true);
	});
};