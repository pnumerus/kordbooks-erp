<template>
  <div>
    <h1>Invoices</h1>
    <Table
      :columns="columns"
      :data="rows"
      :loading="false"
      rowKey="id"
    />
  </div>
</template>

<script setup lang="ts">
import Table from '../components/table.vue'

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'customer', label: 'Customer' },
  { key: 'amount', label: 'Amount' },
  { key: 'status', label: 'Status' },
  { key: 'date', label: 'Date' },
  { key: 'due_date', label: 'Due Date' },
  { key: 'notes', label: 'Notes' }
]

const rows = [
  { id: 1, customer: 'Alice', amount: '$100', status: 'Paid', date: '2026-04-01', due_date: '2026-04-10', notes: 'Paid on time' },
  { id: 2, customer: 'Bob', amount: '$200', status: 'Unpaid', date: '2026-04-05', due_date: '2026-04-15', notes: 'Reminder sent' },
  { id: 3, customer: 'Charlie', amount: '$150', status: 'Paid', date: '2026-04-07', due_date: '2026-04-17', notes: 'Paid late' }
]
</script>