import { createFileRoute } from '@tanstack/react-router';
import SearchResultPage from '../pages/SearchResultPage';

export const Route = createFileRoute('/')({
  component: SearchResultPage,
});

