function generateHtml(resumeData, modules, cssStyle) {
  const cssContent = cssStyle?.cssContent || ''

  let headerHtml = ''
  const sectionHtmls = []

  modules.forEach((mod) => {
    let content = {}
    try {
      content = typeof mod.content === 'string' ? JSON.parse(mod.content) : (mod.content || {})
    } catch { content = {} }

    switch (mod.moduleType) {
      case 'basic_info':
        headerHtml = generateBasicInfo(content)
        break
      case 'education':
        sectionHtmls.push(generateEducation(content))
        break
      case 'work_experience':
        sectionHtmls.push(generateWorkExperience(content))
        break
      case 'project':
        sectionHtmls.push(generateProject(content))
        break
      case 'award':
        sectionHtmls.push(generateAward(content))
        break
    }
  })

  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${resumeData?.title || '简历'}</title>
  <style>${cssContent}</style>
</head>
<body>
  <div class="resume">
    ${headerHtml}
    ${sectionHtmls.join('\n    ')}
  </div>
</body>
</html>`
}

function generateBasicInfo(content) {
  const name = content.name || ''
  const jobIntention = content.jobIntention || ''
  const phone = content.phone || ''
  const email = content.email || ''
  const wechat = content.wechat || ''
  const github = content.github || ''
  const blog = content.blog || ''

  const contactItems = []
  if (phone) contactItems.push(`<span>${phone}</span>`)
  if (email) contactItems.push(`<span>${email}</span>`)
  if (wechat) contactItems.push(`<span>微信: ${wechat}</span>`)
  if (github) contactItems.push(`<span>${github}</span>`)
  if (blog) contactItems.push(`<span>${blog}</span>`)

  return `<header>
    <h1 class="name">${name}</h1>
    ${jobIntention ? `<p class="job-intention">${jobIntention}</p>` : ''}
    ${contactItems.length ? `<div class="contact-info">${contactItems.join(' | ')}</div>` : ''}
  </header>`
}

function generateEducation(content) {
  const school = content.school || ''
  const major = content.major || ''
  const degree = content.degree || ''
  const startDate = content.startDate || ''
  const endDate = content.endDate || ''

  const dateStr = [startDate, endDate].filter(Boolean).join(' - ')

  return `<div class="section">
    <h2 class="section-title">教育经历</h2>
    <div class="timeline-item">
      <div class="timeline-header">
        <span class="school">${school}</span>
        ${dateStr ? `<span class="date">${dateStr}</span>` : ''}
      </div>
      <div>
        ${major ? `<span class="major">${major}</span>` : ''}
        ${degree ? ` · <span class="degree">${degree}</span>` : ''}
      </div>
    </div>
  </div>`
}

function generateWorkExperience(content) {
  const company = content.company || ''
  const position = content.position || ''
  const techStack = content.techStack || ''
  const responsibilities = Array.isArray(content.responsibilities) ? content.responsibilities : []
  const startDate = content.startDate || ''
  const endDate = content.endDate || ''

  const dateStr = [startDate, endDate || '至今'].filter(Boolean).join(' - ')

  const respHtml = responsibilities.length
    ? `<ul class="description">${responsibilities.filter(r => r.trim()).map(r => `<li>${r}</li>`).join('\n        ')}</ul>`
    : ''

  return `<div class="section">
    <h2 class="section-title">工作经历</h2>
    <div class="timeline-item">
      <div class="timeline-header">
        <span class="company">${company}</span>
        ${dateStr ? `<span class="date">${dateStr}</span>` : ''}
      </div>
      ${position ? `<span class="position">${position}</span>` : ''}
      ${techStack ? `<p style="margin-top:0.5rem;font-size:0.9rem;color:var(--gray);">技术栈：${techStack}</p>` : ''}
      ${respHtml}
    </div>
  </div>`
}

function generateProject(content) {
  const projectName = content.projectName || ''
  const role = content.role || ''
  const startDate = content.startDate || ''
  const endDate = content.endDate || ''
  const techStack = content.techStack || ''
  const description = content.description || ''
  const achievements = Array.isArray(content.achievements) ? content.achievements : []

  const dateStr = [startDate, endDate || '至今'].filter(Boolean).join(' - ')

  const achHtml = achievements.length
    ? `<ul class="description">${achievements.filter(a => a.trim()).map(a => `<li>${a}</li>`).join('\n        ')}</ul>`
    : ''

  return `<div class="section">
    <h2 class="section-title">项目经历</h2>
    <div class="project">
      <div class="timeline-header">
        <span class="project-title">${projectName}</span>
        ${dateStr ? `<span class="date">${dateStr}</span>` : ''}
      </div>
      ${role ? `<span class="position">${role}</span>` : ''}
      ${techStack ? `<p style="margin-top:0.5rem;font-size:0.9rem;color:var(--gray);">技术栈：${techStack}</p>` : ''}
      ${description ? `<p class="description" style="border-left:none;padding-left:0;margin-top:0.5rem;">${description}</p>` : ''}
      ${achHtml}
    </div>
  </div>`
}

function generateAward(content) {
  const categories = content.categories
  let certTags = ''

  if (typeof categories === 'string') {
    try {
      const parsed = JSON.parse(categories)
      if (Array.isArray(parsed)) {
        certTags = parsed.flatMap(cat => {
          const items = cat.items || []
          return items.map(i => `<span class="certificate-tag">${i}</span>`).join('\n      ')
        }).join('\n      ')
      }
    } catch {
      certTags = `<span class="certificate-tag">${categories}</span>`
    }
  } else if (Array.isArray(categories)) {
    certTags = categories
      .flatMap(cat => {
        if (typeof cat === 'object' && cat.items) {
          return cat.items.map(i => `<span class="certificate-tag">${i}</span>`)
        }
        return [`<span class="certificate-tag">${cat}</span>`]
      })
      .join('\n      ')
  }

  return `<div class="section">
    <h2 class="section-title">荣誉证书</h2>
    <div>
      ${certTags}
    </div>
  </div>`
}

export { generateHtml }
