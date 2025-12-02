import { createFileRoute } from '@tanstack/react-router'
import PageLayout from "@/components/PageLayout.tsx";

export const Route = createFileRoute('/_page')({
  component: PageLayout,
  shouldReload: false,
})
