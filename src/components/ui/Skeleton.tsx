// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { cn } from '@/lib/utils'

interface SkeletonProps {
  className?: string
  variant?: 'text' | 'card' | 'circle'
}

export function Skeleton({ className, variant = 'text' }: SkeletonProps) {
  const variants = {
    text: 'h-4 w-full rounded-md',
    card: 'h-40 w-full rounded-2xl',
    circle: 'h-10 w-10 rounded-full',
  }

  return (
    <div className={cn('skeleton', variants[variant], className)} />
  )
}
