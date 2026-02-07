// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { cn } from '@/lib/utils'
import type { InputHTMLAttributes } from 'react'
import { forwardRef } from 'react'

interface GlassInputProps extends InputHTMLAttributes<HTMLInputElement> {
  icon?: React.ReactNode
}

export const GlassInput = forwardRef<HTMLInputElement, GlassInputProps>(
  ({ className, icon, ...props }, ref) => {
    return (
      <div className={cn(
        'flex items-center gap-3 h-12 px-4',
        'bg-[rgba(255,255,255,0.03)] backdrop-blur-xl',
        'border border-[rgba(255,255,255,0.06)] rounded-xl',
        'focus-within:border-[rgba(139,139,245,0.3)] focus-within:shadow-[0_0_0_3px_rgba(139,139,245,0.1)]',
        'transition-all duration-200',
        className
      )}>
        {icon && <span className="text-[#6e6e76] flex-shrink-0">{icon}</span>}
        <input
          ref={ref}
          className="flex-1 bg-transparent outline-none text-[#e8e8ea] placeholder-[#4a4a52] text-sm font-medium"
          {...props}
        />
      </div>
    )
  }
)

GlassInput.displayName = 'GlassInput'
