import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import './index.css'
import App from './App.tsx'
import AppLayout from './AppLayout.tsx'
import RoleSelectScreen from './screens/RoleSelectScreen.tsx'
import DispatcherDashboardScreen from './screens/DispatcherDashboardScreen.tsx'
import CreateRequestScreen from './screens/CreateRequestScreen.tsx'
import PriorityResultScreen from './screens/PriorityResultScreen.tsx'
import MatchResultScreen from './screens/MatchResultScreen.tsx'
import DeliveryScreen from './screens/DeliveryScreen.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <Routes>
        {/* Landing Page */}
        <Route path="/" element={<App />} />
        
        {/* Demo Application */}
        <Route path="/app" element={<AppLayout />}>
          <Route index element={<RoleSelectScreen />} />
          <Route path="dashboard" element={<DispatcherDashboardScreen />} />
          <Route path="request/new" element={<CreateRequestScreen />} />
          <Route path="request/priority" element={<PriorityResultScreen />} />
          <Route path="request/match" element={<MatchResultScreen />} />
          <Route path="delivery" element={<DeliveryScreen />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </StrictMode>,
)
