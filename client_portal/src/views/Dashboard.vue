<template>
  <div class="min-h-screen bg-slate-50 p-6 text-slate-900">
    <div class="mx-auto max-w-5xl space-y-6">
      <header class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-slate-500">Client Portal</p>
        <h1 class="mt-1 text-2xl font-semibold">Dashboard</h1>
        <p class="mt-2 text-sm text-slate-600">
          Welcome back. Here is a simple overview of your portal.
        </p>
      </header>

      <section class="grid gap-4 md:grid-cols-3">
        <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
          <p class="text-sm text-slate-500">Screen width</p>
          <p class="mt-2 text-2xl font-semibold">{{ width }}px</p>
        </div>

        <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
          <p class="text-sm text-slate-500">Screen height</p>
          <p class="mt-2 text-2xl font-semibold">{{ height }}px</p>
        </div>

        <div class="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
          <p class="text-sm text-slate-500">Theme preference</p>
          <p class="mt-2 text-2xl font-semibold">
            {{ isDark ? 'Dark' : 'Light' }}
          </p>
        </div>
      </section>

      <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-slate-500">Current time</p>
        <p class="mt-2 text-lg font-medium">
          {{ now.toLocaleString() }}
        </p>

        <p class="mt-4 text-sm text-slate-600">
          Mobile layout:
          <span class="font-medium">{{ isMobile ? 'Yes' : 'No' }}</span>
        </p>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useNow, usePreferredDark, useWindowSize } from '@vueuse/core'

const { width, height } = useWindowSize()
const isDark = usePreferredDark()
const now = useNow()

const isMobile = computed(() => width.value < 768)
</script>