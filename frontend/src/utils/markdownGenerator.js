function generateMarkdown(resumeData, modules) {
  let headerMd = ''
  const sectionMds = []
  const generatedSections = new Set()

  modules.forEach((mod) => {
    let content = {}
    try {
      content = typeof mod.content === 'string' ? JSON.parse(mod.content) : (mod.content || {})
    } catch { content = {} }

    const skipTitle = generatedSections.has(mod.moduleType)
    generatedSections.add(mod.moduleType)

    switch (mod.moduleType) {
      case 'basic_info':
        headerMd = generateBasicInfo(content)
        break
      case 'education':
        sectionMds.push(generateEducation(content, skipTitle))
        break
      case 'work_experience':
        sectionMds.push(generateWorkExperience(content, skipTitle))
        break
      case 'project':
        sectionMds.push(generateProject(content, skipTitle))
        break
      case 'award':
        sectionMds.push(generateAward(content, skipTitle))
        break
    }
  })

  const parts = []
  if (headerMd) parts.push(headerMd)
  parts.push(...sectionMds)

  return parts.join('\n\n')
}

function generateBasicInfo(content) {
  const name = content.name || ''
  const jobIntention = content.jobIntention || ''
  const phone = content.phone || ''
  const email = content.email || ''
  const wechat = content.wechat || ''
  const github = content.github || ''
  const blog = content.blog || ''
  const leetcode = content.leetcode || ''
  const workYears = content.workYears || ''
  const targetCity = content.targetCity || ''
  const hometown = content.hometown || ''
  const summary = content.summary || ''
  const salaryRange = content.salaryRange || ''
  const expectedEntryDate = content.expectedEntryDate || ''
  const isPartyMember = content.isPartyMember || false

  const lines = []


  lines.push(`# ${name || '未命名'}`)

  const contactItems = []
  if (jobIntention) contactItems.push(jobIntention)
  if (phone) contactItems.push(`📱 ${phone}`)
  if (email) contactItems.push(`✉️ ${email}`)
  if (wechat) contactItems.push(`💬 ${wechat}`)
  if (workYears) contactItems.push(`💼 ${workYears}`)
  if (targetCity) contactItems.push(`📍 ${targetCity}`)
  if (github) contactItems.push(`🌐 ${github}`)

  if (contactItems.length) {
    lines.push('')
    lines.push(contactItems.join(' | '))
  }

  if (summary) {
    lines.push('')
    lines.push(`> ${summary}`)
  }

  return lines.join('\n')
}

function generateEducation(content, skipTitle = false) {
  const school = content.school || ''
  const department = content.department || ''
  const major = content.major || ''
  const degree = content.degree || ''
  const startDate = content.startDate || ''
  const endDate = content.endDate || ''
  const is211 = content.is211 || false
  const is985 = content.is985 || false
  const isDoubleFirst = content.isDoubleFirst || false
  const schoolLogo = content.schoolLogo || ''

  const lines = []

  if (!skipTitle) lines.push('## 教育经历')

  const dateStr = [startDate, endDate].filter(Boolean).join(' ~ ')

  const detailParts = []
  if (department) detailParts.push(department)
  if (major) detailParts.push(major)
  if (degree) detailParts.push(degree)
  const detailStr = detailParts.length ? ` — ${detailParts.join(' · ')}` : ''

  const logoStr = schoolLogo ? `![${school}](${schoolLogo}) ` : ''

  lines.push(`**${logoStr}${school}**${detailStr}${dateStr ? ` | ${dateStr}` : ''}`)

  const tags = []
  if (is211) tags.push('`211`')
  if (is985) tags.push('`985`')
  if (isDoubleFirst) tags.push('`双一流`')
  if (tags.length) lines.push(tags.join(' '))

  return lines.join('\n')
}

function generateWorkExperience(content, skipTitle = false) {
  const company = content.company || ''
  const position = content.position || ''
  const techStack = content.techStack || ''
  const projectName = content.projectName || ''
  const projectDescription = content.projectDescription || ''
  const responsibilities = Array.isArray(content.responsibilities) ? content.responsibilities : []
  const startDate = content.startDate || ''
  const endDate = content.endDate || ''

  const lines = []

  if (!skipTitle) lines.push('## 工作经历')

  const dateStr = [startDate, endDate || '至今'].filter(Boolean).join(' ~ ')

  const headerParts = []
  if (company) headerParts.push(`**${company}**`)
  if (position) headerParts.push(position)
  lines.push(`${headerParts.join(' | ')}${dateStr ? ` | ${dateStr}` : ''}`)

  if (techStack) lines.push(`技术栈：${techStack}`)

  responsibilities.filter(r => r.trim()).forEach(r => {
    lines.push(`- ${r}`)
  })

  if (projectName || projectDescription) {
    lines.push('')
    if (projectName) lines.push(`**${projectName}**`)
    if (projectDescription) lines.push(projectDescription)
  }

  return lines.join('\n')
}

function generateProject(content, skipTitle = false) {
  const projectName = content.projectName || ''
  const role = content.role || ''
  const startDate = content.startDate || ''
  const endDate = content.endDate || ''
  const techStack = content.techStack || ''
  const description = content.description || ''
  const responsibilities = Array.isArray(content.responsibilities) ? content.responsibilities : []
  const achievements = Array.isArray(content.achievements) ? content.achievements : []

  const lines = []

  if (!skipTitle) lines.push('## 项目经历')

  const dateStr = [startDate, endDate || '至今'].filter(Boolean).join(' ~ ')

  const headerParts = []
  if (projectName) headerParts.push(`**${projectName}**`)
  if (role) headerParts.push(role)
  lines.push(`${headerParts.join(' | ')}${dateStr ? ` | ${dateStr}` : ''}`)

  if (techStack) lines.push(`技术栈：${techStack}`)

  if (description) {
    lines.push('')
    lines.push(`**项目描述**：${description}`)
  }

  if (responsibilities.length) {
    lines.push('')
    lines.push('**工作内容**')
    responsibilities.filter(r => r.trim()).forEach(r => {
      lines.push(`- ${r}`)
    })
  }

  if (achievements.length) {
    lines.push('')
    lines.push('**项目成果**')
    achievements.filter(a => a.trim()).forEach(a => {
      lines.push(`- ${a}`)
    })
  }

  return lines.join('\n')
}

function generateAward(content, skipTitle = false) {
  let items = []

  const categories = content.categories
  if (Array.isArray(categories)) {
    items = categories.filter(c => String(c).trim())
  } else if (typeof categories === 'string') {
    try {
      const parsed = JSON.parse(categories)
      if (Array.isArray(parsed)) {
        items = parsed.flatMap(cat => {
          if (typeof cat === 'object' && cat.items) return cat.items
          return [cat]
        })
      } else {
        items = [categories]
      }
    } catch {
      items = [categories]
    }
  }

  const lines = []

  if (!skipTitle) lines.push('## 荣誉证书')

  if (items.length) {
    lines.push(items.map(c => `\`${c}\``).join(' '))
  }

  return lines.join('\n')
}

export { generateMarkdown }
