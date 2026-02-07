// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState, useEffect, useRef, useCallback } from 'react'
import { motion } from 'framer-motion'
import { springs } from '@/lib/motion'
import { formatDuration } from '@/lib/utils'
import { useApp } from '@/lib/store'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import { Play, Pause, RotateCcw, Coffee, Brain } from 'lucide-react'

const FOCUS_TIME = 25 * 60
const BREAK_TIME = 5 * 60

export function TimerPage() {
  const { dispatch } = useApp()
  const [timeLeft, setTimeLeft] = useState(FOCUS_TIME)
  const [isRunning, setIsRunning] = useState(false)
  const [mode, setMode] = useState<'focus' | 'break'>('focus')
  const startTimeRef = useRef<number | null>(null)
  const intervalRef = useRef<number | null>(null)

  const totalTime = mode === 'focus' ? FOCUS_TIME : BREAK_TIME
  const progress = ((totalTime - timeLeft) / totalTime) * 100
  const radius = 140
  const circumference = radius * 2 * Math.PI
  const offset = circumference - (progress / 100) * circumference

  const stop = useCallback(() => {
    setIsRunning(false)
    if (intervalRef.current) clearInterval(intervalRef.current)
    if (startTimeRef.current && mode === 'focus') {
      const duration = Math.floor((Date.now() - startTimeRef.current) / 1000)
      if (duration > 30) {
        dispatch({
          type: 'ADD_SESSION',
          payload: {
            id: `session-${Date.now()}`,
            subjectId: 'general',
            startedAt: startTimeRef.current,
            duration,
          },
        })
      }
    }
    startTimeRef.current = null
  }, [mode, dispatch])

  useEffect(() => {
    if (isRunning) {
      intervalRef.current = window.setInterval(() => {
        setTimeLeft(prev => {
          if (prev <= 1) {
            stop()
            return 0
          }
          return prev - 1
        })
      }, 1000)
    }
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
    }
  }, [isRunning, stop])

  const start = () => {
    startTimeRef.current = Date.now()
    setIsRunning(true)
  }

  const reset = () => {
    stop()
    setTimeLeft(totalTime)
  }

  const toggleMode = (newMode: 'focus' | 'break') => {
    stop()
    setMode(newMode)
    setTimeLeft(newMode === 'focus' ? FOCUS_TIME : BREAK_TIME)
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] space-y-10">
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
        className="text-center"
      >
        <span className="text-[11px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] mb-2 block">
          Pomodoro Timer
        </span>
        <h1 className="text-3xl font-extrabold tracking-tight text-[#e8e8ea]">
          {mode === 'focus' ? 'Focustijd' : 'Pauze'}
        </h1>
      </motion.div>

      {/* Mode toggle */}
      <GlassPanel className="p-1.5 flex gap-1">
        {([
          { id: 'focus' as const, icon: Brain, label: 'Focus' },
          { id: 'break' as const, icon: Coffee, label: 'Pauze' },
        ]).map((tab) => (
          <motion.button
            key={tab.id}
            onClick={() => toggleMode(tab.id)}
            className={`relative flex items-center gap-2 px-5 py-2 rounded-xl text-sm font-medium transition-colors cursor-pointer ${
              mode === tab.id ? 'text-[#e8e8ea]' : 'text-[#6e6e76] hover:text-[#e8e8ea]'
            }`}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            {mode === tab.id && (
              <motion.div
                layoutId="timer-mode"
                className="absolute inset-0 bg-[rgba(139,139,245,0.12)] border border-[rgba(139,139,245,0.15)] rounded-xl"
                transition={springs.stiff}
              />
            )}
            <tab.icon size={16} className="relative z-10" />
            <span className="relative z-10">{tab.label}</span>
          </motion.button>
        ))}
      </GlassPanel>

      {/* Timer circle */}
      <motion.div
        className="relative"
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={springs.bouncy}
      >
        <GlassPanel className="w-[340px] h-[340px] rounded-full flex items-center justify-center" intensity="strong">
          {/* SVG ring */}
          <svg width="320" height="320" className="absolute rotate-[-90deg]">
            <circle
              cx="160"
              cy="160"
              r={radius}
              fill="none"
              stroke="rgba(255,255,255,0.04)"
              strokeWidth="4"
            />
            <motion.circle
              cx="160"
              cy="160"
              r={radius}
              fill="none"
              stroke={mode === 'focus' ? '#8b8bf5' : '#10b981'}
              strokeWidth="4"
              strokeLinecap="round"
              strokeDasharray={circumference}
              animate={{ strokeDashoffset: offset }}
              transition={springs.smooth}
            />
          </svg>

          {/* Time display */}
          <div className="text-center z-10">
            <motion.div
              className="text-6xl font-extrabold text-[#e8e8ea] tracking-tight tabular-nums"
              key={timeLeft}
              initial={{ scale: 1.05 }}
              animate={{ scale: 1 }}
              transition={{ duration: 0.1 }}
            >
              {formatDuration(timeLeft)}
            </motion.div>
            <p className="text-[11px] uppercase tracking-wider text-[#6e6e76] font-medium mt-2">
              {mode === 'focus' ? 'Blijf gefocust' : 'Neem een pauze'}
            </p>
          </div>

          {/* Pulsing glow when running */}
          {isRunning && (
            <motion.div
              className="absolute inset-0 rounded-full"
              style={{
                boxShadow: `0 0 40px ${mode === 'focus' ? 'rgba(139,139,245,0.1)' : 'rgba(16,185,129,0.1)'}`,
              }}
              animate={{ opacity: [0.3, 0.6, 0.3] }}
              transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
            />
          )}
        </GlassPanel>
      </motion.div>

      {/* Controls */}
      <div className="flex items-center gap-4">
        <GlassButton variant="ghost" icon={<RotateCcw size={20} />} onClick={reset} />
        <GlassButton
          variant="accent"
          size="lg"
          icon={isRunning ? <Pause size={22} /> : <Play size={22} />}
          onClick={isRunning ? stop : start}
          className="w-16 h-16 rounded-2xl"
        />
        <div className="w-10" /> {/* Spacer for symmetry */}
      </div>
    </div>
  )
}
