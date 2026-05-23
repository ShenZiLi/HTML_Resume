function generateHtml(resumeData, modules, cssStyle) {
  const cssContent = cssStyle?.cssContent || ''

  let headerHtml = ''
  const sectionHtmls = []
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
        headerHtml = generateBasicInfo(content)
        break
      case 'education':
        sectionHtmls.push(generateEducation(content, skipTitle))
        break
      case 'work_experience':
        sectionHtmls.push(generateWorkExperience(content, skipTitle))
        break
      case 'project':
        sectionHtmls.push(generateProject(content, skipTitle))
        break
      case 'award':
        sectionHtmls.push(generateAward(content, skipTitle))
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
  const leetcode = content.leetcode || ''
  const workYears = content.workYears || ''
  const targetCity = content.targetCity || ''
  const hometown = content.hometown || ''
  const summary = content.summary || ''
  const salaryRange = content.salaryRange || ''
  const expectedEntryDate = content.expectedEntryDate || ''
  const isPartyMember = content.isPartyMember || false
  const photo = content.photo || ''
  const photoBorder = content.photoBorder || false

  const contactItems = []
  if (phone) contactItems.push(`<span>📱 ${phone}</span>`)
  if (email) contactItems.push(`<span>✉️ ${email}</span>`)
  if (wechat) contactItems.push(`<span>💬 ${wechat}</span>`)
  if (github) contactItems.push(`<a href="${github}" target="_blank">GitHub</a>`)
  if (blog) contactItems.push(`<a href="${blog}" target="_blank">博客</a>`)
  if (leetcode) contactItems.push(`<span>LeetCode: ${leetcode}</span>`)
  if (workYears) contactItems.push(`<span>👨 ${workYears}</span>`)
  if (targetCity) contactItems.push(`<span>📍 ${targetCity}</span>`)
  if (hometown) contactItems.push(`<span>🏠 ${hometown}</span>`)
  if (salaryRange) contactItems.push(`<span>💰 ${salaryRange}</span>`)
  if (expectedEntryDate) contactItems.push(`<span>📅 ${expectedEntryDate}</span>`)
  if (isPartyMember) contactItems.push(`<span>🚩 中共党员</span>`)

  const photoStyle = photoBorder ? 'style="border: 3px solid rgba(255,255,255,0.3);"' : ''
  const photoHtml = photo ? `<img class="avatar" src="${photo}" alt="照片" ${photoStyle}/>` : ''

  return `<header>
    <div class="header-content">
      <h1 class="name">${name}</h1>
      ${jobIntention ? `<p class="job-intention">${jobIntention}</p>` : ''}
      ${contactItems.length ? `<div class="contact-info">${contactItems.join(' | ')}</div>` : ''}
      ${summary ? `<p class="summary">${summary}</p>` : ''}
    </div>
    ${photoHtml}
  </header>`
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

  const dateStr = [startDate, endDate].filter(Boolean).join(' - ')

  const tags = []
  if (is211) tags.push('<span class="certificate-tag">211</span>')
  if (is985) tags.push('<span class="certificate-tag">985</span>')
  if (isDoubleFirst) tags.push('<span class="certificate-tag">双一流</span>')

  const logoHtml = schoolLogo ? `<img class="school-logo" src="${schoolLogo}" alt="${school}" />` : ''

  return `<div class="section">
    ${skipTitle ? '' : '<h2 class="section-title">教育经历</h2>'}
    <div class="timeline-item">
      ${logoHtml}
      <div class="timeline-header">
        <span class="school">${school}</span>
        ${dateStr ? `<span class="date">${dateStr}</span>` : ''}
      </div>
      <div>
        ${department ? `<span class="department">${department}</span>` : ''}
        ${major ? `<span class="major">${major}</span>` : ''}
        ${degree ? ` · <span class="degree">${degree}</span>` : ''}
      </div>
      ${tags.length ? `<div style="margin-top:0.5rem;">${tags.join(' ')}</div>` : ''}
    </div>
  </div>`
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

  const dateStr = [startDate, endDate || '至今'].filter(Boolean).join(' - ')

  const respHtml = responsibilities.length
    ? `<ul class="description">${responsibilities.filter(r => r.trim()).map(r => `<li>${r}</li>`).join('\n        ')}</ul>`
    : ''

  const projectHtml = (projectName || projectDescription)
    ? `<div class="project" style="margin-top:1rem;">
        ${projectName ? `<div class="project-title">${projectName}</div>` : ''}
        ${projectDescription ? `<p class="description" style="border-left:none;padding-left:0;margin-top:0.5rem;">${projectDescription}</p>` : ''}
      </div>`
    : ''

  return `<div class="section">
    ${skipTitle ? '' : '<h2 class="section-title">工作经历</h2>'}
    <div class="timeline-item">
      <div class="timeline-header">
        <span class="company">${company}</span>
        ${dateStr ? `<span class="date">${dateStr}</span>` : ''}
      </div>
      ${position ? `<span class="position">${position}</span>` : ''}
      ${techStack ? `<p style="margin-top:0.5rem;font-size:0.9rem;color:var(--gray);">技术栈：${techStack}</p>` : ''}
      ${respHtml}
      ${projectHtml}
    </div>
  </div>`
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

  const dateStr = [startDate, endDate || '至今'].filter(Boolean).join(' – ')

  const descHtml = description
    ? `<div class="description"><p><strong>项目描述</strong>：${description}</p></div>`
    : ''

  const respHtml = responsibilities.length
    ? `<div class="description"><p><strong>工作内容</strong></p><ul>${responsibilities.filter(r => r.trim()).map(r => `<li>${r}</li>`).join('\n        ')}</ul></div>`
    : ''

  const achHtml = achievements.length
    ? `<div class="description"><p><strong>项目成果</strong></p><ul>${achievements.filter(a => a.trim()).map(a => `<li>${a}</li>`).join('\n        ')}</ul></div>`
    : ''

  return `<div class="section">
    ${skipTitle ? '' : '<h2 class="section-title">项目经历</h2>'}
    <div class="project">
      <div class="project-meta">
        <span class="project-title">${projectName}</span>
        ${dateStr ? `<span class="date">${dateStr}</span>` : ''}
      </div>
      ${role ? `<div class="company">${role}</div>` : ''}
      ${techStack ? `<p style="margin-top:0.5rem;font-size:0.9rem;color:var(--gray);">技术栈：${techStack}</p>` : ''}
      ${descHtml}
      ${respHtml}
      ${achHtml}
    </div>
  </div>`
}

function generateAward(content, skipTitle = false) {
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
    ${skipTitle ? '' : '<h2 class="section-title">荣誉证书</h2>'}
    <div>
      ${certTags}
    </div>
  </div>`
}

export { generateHtml }
