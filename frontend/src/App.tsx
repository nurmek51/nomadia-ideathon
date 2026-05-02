import Navbar from './components/Navbar';
import Hero from './components/Hero';
import Problem from './components/Problem';
import Layers from './components/Layers';
import SystemFlow from './components/SystemFlow';
import Footer from './components/Footer';

function App() {
  return (
    <div className="min-h-screen border-x-2 border-neutral/10 max-w-7xl mx-auto flex flex-col">
      <Navbar />
      <Hero />
      <Problem />
      <Layers />
      <SystemFlow />
      <Footer />
    </div>
  );
}

export default App;
