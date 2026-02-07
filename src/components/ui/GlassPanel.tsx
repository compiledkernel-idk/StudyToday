// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion, type HTMLMotionProps } from 'framer-motion'
import { cn } from '@/lib/utils'
import { forwardRef } from 'react'

interface GlassPanelProps extends HTMLMotionProps<'div'> {
  intensity?: 'subtle' | 'medium' | 'strong'
  hover?: boolean
  glow?: 'none' | 'accent' | 'correct' | 'wrong'
}

const intensityMap = {
  subtle: 'bg-[rgba(255,255,255,0.02)] backdrop-blur-[30px]',
  medium: 'bg-[rgba(255,255,255,0.04)] backdrop-blur-[40px]',
  strong: 'bg-[rgba(255,255,255,0.08)] backdrop-blur-[60px] saturate-[1.4]',
}

const glowMap = {
  none: '',
  accent: 'shadow-[0_0_24px_rgba(139,139,245,0.2)]',
  correct: 'shadow-[0_0_24px_rgba(16,185,129,0.3)]',
  wrong: 'shadow-[0_0_24px_rgba(239,68,68,0.3)]',
}

export const GlassPanel = forwardRef<HTMLDivElement, GlassPanelProps>(
  ({ className, intensity = 'medium', hover = false, glow = 'none', children, ...props }, ref) => {
    return (
      <motion.div
        ref={ref}
        className={cn(
          'border border-[rgba(255,255,255,0.06)] rounded-2xl',
          'shadow-[0_8px_32px_rgba(0,0,0,0.12)]',
          'relative overflow-hidden',
          intensityMap[intensity],
          glowMap[glow],
          hover && 'transition-all duration-200 hover:bg-[rgba(255,255,255,0.06)] hover:border-[rgba(255,255,255,0.1)] hover:shadow-[0_12px_48px_rgba(0,0,0,0.18)] hover:-translate-y-1',
          className
        )}
        {...props}
      >
        {/* Inner highlight - top edge light reflection */}
        <div className="absolute top-0 left-4 right-4 h-px bg-gradient-to-r from-transparent via-[rgba(255,255,255,0.06)] to-transparent pointer-events-none" />
        {children}
      </motion.div>
    )
  }
)

GlassPanel.displayName = 'GlassPanel'
