import { Link, useParams } from '@tanstack/react-router';

function VehicleDetailPage() {
  const { vehicleId } = useParams({ from: '/_page/vehicle/$vehicleId' });
  console.log("vehicleId", vehicleId);

  // Sample vehicle details based on ID
  const vehicleDetails: Record<string, { name: string; price: string; description: string; specs: string[] }> = {
    '1': {
      name: 'Toyota Camry 2024',
      price: '$28,000',
      description: 'A reliable and comfortable midsize sedan with excellent fuel economy.',
      specs: ['2.5L 4-Cylinder Engine', '203 HP', '32 MPG Combined', 'All-Wheel Drive Available'],
    },
    '2': {
      name: 'Honda Accord 2024',
      price: '$30,000',
      description: 'Refined sedan offering a spacious interior and advanced safety features.',
      specs: ['1.5L Turbo Engine', '192 HP', '33 MPG Combined', 'Honda Sensing Suite'],
    },
    '3': {
      name: 'Tesla Model 3 2024',
      price: '$42,000',
      description: 'Electric sedan with cutting-edge technology and impressive performance.',
      specs: ['Dual Motor AWD', '358 HP', '272 Mile Range', 'Autopilot Included'],
    },
  };

  const vehicle = vehicleDetails[vehicleId];

  if (!vehicle) {
    return (
      <div className="p-6">
        <h1 className="text-3xl font-bold mb-4">Vehicle Not Found</h1>
        <Link to="/" className="text-blue-600 hover:underline">
          ← Back to Search Results
        </Link>
      </div>
    );
  }

  return (
    <div className="p-6">
      <Link to="/" className="text-blue-600 hover:underline mb-4 inline-block">
        ← Back to Search Results
      </Link>
      <div className="mt-4">
        <h1 className="text-3xl font-bold mb-2">{vehicle.name}</h1>
        <p className="text-2xl text-green-600 font-semibold mb-4">{vehicle.price}</p>
        <p className="text-gray-700 dark:text-gray-300 mb-6">{vehicle.description}</p>

        <h2 className="text-xl font-semibold mb-3">Specifications</h2>
        <ul className="list-disc list-inside space-y-2">
          {vehicle.specs.map((spec, index) => (
            <li key={index} className="text-gray-700 dark:text-gray-300">
              {spec}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default VehicleDetailPage;

