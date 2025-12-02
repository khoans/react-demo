import { createFileRoute } from '@tanstack/react-router'
import { VehicleDetailPage } from '@/pages'

export const Route = createFileRoute('/_page/vehicle/$vehicleId')({
  component: VehicleDetailPage,
})
