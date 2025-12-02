import { Link } from '@tanstack/react-router';

function SearchResultPage() {
  // Sample vehicle data
  const vehicles = [
    { id: '1', name: 'Toyota Camry 2024', price: '$28,000' },
    { id: '2', name: 'Honda Accord 2024', price: '$30,000' },
    { id: '3', name: 'Tesla Model 3 2024', price: '$42,000' },
  ];

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">Search Results</h1>
      <div className="grid gap-4">
        {vehicles.map((vehicle) => (
          <Link
            key={vehicle.id}
            to="/vehicle/$vehicleId"
            params={{ vehicleId: vehicle.id }}
            className="block p-4 border rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <h2 className="text-xl font-semibold">{vehicle.name}</h2>
            <p className="text-gray-600 dark:text-gray-400">{vehicle.price}</p>
          </Link>
        ))}
      </div>
    </div>
  );
}

export default SearchResultPage;

