// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useReducer, useEffect, Component, type ReactNode } from 'react'
import { BrowserRouter } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Background } from '@/components/layout/Background'
import { Sidebar } from '@/components/layout/Sidebar'
import { MainPanel } from '@/components/layout/MainPanel'
import { CommandPalette } from '@/components/layout/CommandPalette'
import { AppContext, appReducer, initialState } from '@/lib/store'
import { sampleSubjects } from '@/lib/sample-content'
import { springs } from '@/lib/motion'

class ErrorBoundary extends Component<{ children: ReactNode }, { error: Error | null }> {
  state = { error: null as Error | null }

  static getDerivedStateFromError(error: Error) {
    return { error }
  }

  render() {
    if (this.state.error) {
      return (
        <div style={{ background: '#111113', color: '#e8e8ea', padding: 40, fontFamily: 'Inter, system-ui, sans-serif', height: '100vh' }}>
          <h1 style={{ color: '#ef4444', marginBottom: 16 }}>Er ging iets mis</h1>
          <pre style={{ color: '#6e6e76', fontSize: 13, whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>
            {this.state.error.message}
            {'\n\n'}
            {this.state.error.stack}
          </pre>
        </div>
      )
    }
    return this.props.children
  }
}

function App() {
  const [state, dispatch] = useReducer(appReducer, initialState)

  // Load sample content on mount (simulates GitHub sync)
  useEffect(() => {
    dispatch({ type: 'SET_SYNC_STATUS', payload: 'syncing' })

    const timer = setTimeout(() => {
      dispatch({ type: 'SET_SUBJECTS', payload: sampleSubjects })
      dispatch({ type: 'SET_SYNC_STATUS', payload: 'done' })
      dispatch({ type: 'SET_LAST_SHA', payload: 'sample-local' })
    }, 1500)

    return () => clearTimeout(timer)
  }, [])

  return (
    <ErrorBoundary>
      <AppContext.Provider value={{ state, dispatch }}>
        <BrowserRouter>
          <div className="w-full h-full relative">
            <motion.div
              className="w-full h-full"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={springs.smooth}
            >
              <Background />
              <Sidebar />
              <MainPanel />
              <CommandPalette />
            </motion.div>
          </div>
        </BrowserRouter>
      </AppContext.Provider>
    </ErrorBoundary>
  )
}

export default App
