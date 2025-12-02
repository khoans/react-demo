import { createFileRoute } from '@tanstack/react-router';
import VehicleDetailPage from '../pages/VehicleDetailPage';

export const Route = createFileRoute('/vehicle/$vehicleId')({
  component: VehicleDetailPage,
});

