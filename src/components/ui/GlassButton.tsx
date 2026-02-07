// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion } from 'framer-motion'
import { cn } from '@/lib/utils'
import { springs } from '@/lib/motion'
import type { ReactNode, ButtonHTMLAttributes } from 'react'

interface GlassButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'accent' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  icon?: ReactNode
  children?: ReactNode
}

export function GlassButton({
  className,
  variant = 'default',
  size = 'md',
  icon,
  children,
  disabled,
  ...props
}: GlassButtonProps) {
  const variants = {
    default: 'bg-[rgba(255,255,255,0.04)] border-[rgba(255,255,255,0.06)] hover:bg-[rgba(255,255,255,0.08)] hover:border-[rgba(255,255,255,0.1)]',
    accent: 'bg-[rgba(139,139,245,0.15)] border-[rgba(139,139,245,0.2)] hover:bg-[rgba(139,139,245,0.25)] hover:border-[rgba(139,139,245,0.3)] text-[#8b8bf5]',
    ghost: 'bg-transparent border-transparent hover:bg-[rgba(255,255,255,0.04)]',
  }

  const sizes = {
    sm: 'h-8 px-3 text-xs gap-1.5 rounded-lg',
    md: 'h-10 px-4 text-sm gap-2 rounded-xl',
    lg: 'h-12 px-6 text-base gap-2.5 rounded-xl',
  }

  return (
    <motion.button
      whileHover={disabled ? {} : { scale: 1.02 }}
      whileTap={disabled ? {} : { scale: 0.98 }}
      transition={springs.bouncy}
      className={cn(
        'inline-flex items-center justify-center font-medium',
        'backdrop-blur-xl border transition-colors duration-200',
        'text-[#e8e8ea] cursor-pointer select-none',
        'disabled:opacity-40 disabled:cursor-not-allowed disabled:blur-[0.5px]',
        variants[variant],
        sizes[size],
        className
      )}
      disabled={disabled}
      {...(props as any)}
    >
      {icon && <span className="flex-shrink-0">{icon}</span>}
      {children}
    </motion.button>
  )
}
