// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useEffect, useRef } from 'react'
import confetti from 'canvas-confetti'

interface ConfettiEffectProps {
  trigger: boolean
}

export function ConfettiEffect({ trigger }: ConfettiEffectProps) {
  const hasFired = useRef(false)

  useEffect(() => {
    if (trigger && !hasFired.current) {
      hasFired.current = true
      confetti({
        particleCount: 80,
        spread: 60,
        origin: { y: 0.7 },
        colors: ['#8b8bf5', '#10b981', '#e8e8ea', '#6e6e76'],
        gravity: 1.2,
        scalar: 0.8,
        drift: 0,
        ticks: 150,
      })
    }
  }, [trigger])

  return null
}
