// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion, useMotionValue, useTransform } from 'framer-motion'
import { useEffect, useRef } from 'react'

export function Background() {
  const mouseX = useMotionValue(0.5)
  const mouseY = useMotionValue(0.5)

  const gradientX = useTransform(mouseX, [0, 1], ['20%', '30%'])
  const gradientY = useTransform(mouseY, [0, 1], ['40%', '60%'])

  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      mouseX.set(e.clientX / window.innerWidth)
      mouseY.set(e.clientY / window.innerHeight)
    }
    window.addEventListener('mousemove', handleMove)
    return () => window.removeEventListener('mousemove', handleMove)
  }, [mouseX, mouseY])

  return (
    <div className="fixed inset-0 overflow-hidden bg-[#0d0d0f]">
      {/* Base gradient mesh */}
      <div className="absolute inset-0 bg-mesh" />

      {/* Interactive gradient orb that follows mouse subtly */}
      <motion.div
        className="absolute w-[600px] h-[600px] rounded-full"
        style={{
          left: gradientX,
          top: gradientY,
          background: 'radial-gradient(circle, rgba(139, 139, 245, 0.03) 0%, transparent 70%)',
          filter: 'blur(80px)',
          transform: 'translate(-50%, -50%)',
        }}
      />

      {/* Floating glass orbs */}
      <motion.div
        className="absolute w-32 h-32 rounded-full bg-[rgba(139,139,245,0.02)] blur-xl"
        style={{ top: '15%', right: '20%' }}
        animate={{
          y: [0, -15, 8, 0],
          rotate: [0, 2, -1, 0],
          scale: [1, 1.05, 0.98, 1],
        }}
        transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
      />
      <motion.div
        className="absolute w-48 h-48 rounded-full bg-[rgba(100,100,200,0.015)] blur-2xl"
        style={{ bottom: '20%', left: '10%' }}
        animate={{
          y: [0, 12, -8, 0],
          rotate: [0, -1, 2, 0],
          scale: [1, 0.97, 1.03, 1],
        }}
        transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
      />
      <motion.div
        className="absolute w-24 h-24 rounded-full bg-[rgba(139,139,245,0.025)] blur-xl"
        style={{ top: '60%', right: '35%' }}
        animate={{
          y: [0, -8, 12, 0],
          x: [0, 5, -3, 0],
        }}
        transition={{ duration: 7, repeat: Infinity, ease: 'easeInOut', delay: 4 }}
      />

      {/* Very subtle noise texture overlay */}
      <div className="absolute inset-0 opacity-[0.015]" style={{
        backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")`,
      }} />
    </div>
  )
}
