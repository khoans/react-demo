import { createFileRoute, redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/_page/')({
  beforeLoad: () => {
    throw redirect({ to: '/search-result-page' })
  },
})
