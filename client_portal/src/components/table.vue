<script setup lang="ts">
interface Column {
  key: string
  label: string
  format?: (value: any, row: Record<string, any>) => string
}

defineProps<{
  columns: Column[]
  data: Record<string, any>[]
  loading?: boolean
  rowKey?: string // Unique field for Vue's list rendering (e.g., 'name', 'id')
}>()
</script>

<template>
  <div class="overflow-x-auto bg-white rounded-xl border border-gray-200 shadow-sm relative">
    <!-- Subtle fade indicator: shows content is scrollable on mobile -->
    <div 
      class="absolute right-0 top-0 bottom-0 w-10 bg-gradient-to-l from-white via-white/80 to-transparent pointer-events-none z-10"
      aria-hidden="true"
    />
    
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
        <tr>
          <th
            v-for="col in columns"
            :key="col.key"
            class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
          >
            {{ col.label }}
          </th>
        </tr>
      </thead>
      
      <tbody class="bg-white divide-y divide-gray-200">
        <!-- Loading State -->
        <tr v-if="loading">
          <td :colspan="columns.length" class="px-4 py-8 text-center text-gray-500">
            Loading...
          </td>
        </tr>
        
        <!-- Empty State -->
        <tr v-else-if="data.length === 0">
          <td :colspan="columns.length" class="px-4 py-8 text-center text-gray-500">
            No data found
          </td>
        </tr>
        
        <!-- Data Rows -->
        <tr 
          v-else 
          v-for="row in data" 
          :key="rowKey ? row[rowKey] : row.name" 
          class="hover:bg-gray-50 transition"
        >
          <td 
            v-for="col in columns" 
            :key="col.key" 
            class="px-4 py-3 whitespace-nowrap"
          >
            <!-- Dynamic slot for custom cell rendering, falls back to default/format -->
            <slot :name="`cell-${col.key}`" :row="row" :value="row[col.key]">
              {{ col.format ? col.format(row[col.key], row) : row[col.key] }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>