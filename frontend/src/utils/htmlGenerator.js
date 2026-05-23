function generateHtml(resumeData, modules, cssStyle) {
  const cssContent = cssStyle?.css_content || ''

  const moduleHtml = modules
    .map((mod) => {
      const content = mod.content || {}
      switch (mod.module_type) {
        case 'basic_info':
          return generateBasicInfo(content)
        case 'education':
          return generateEducation(content)
        case 'work_experience':
          return generateWorkExperience(content)
        case 'project':
          return generateProject(content)
        case 'award':
          return generateAward(content)
        default:
          return ''
      }
    })
    .join('\n')

  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${resumeData?.title || '简历'}</title>
  <style>${cssContent}</style>
</head>
<body>
  <div class="resume-container">
    ${moduleHtml}
  </div>
</body>
</html>`
}

function generateBasicInfo(content) {
  const name = content.name || ''
  const jobIntention = content.job_intention || ''
  const phone = content.phone || ''
  const email = content.email || ''
  const wechat = content.wechat || ''

  const contactItems = []
  if (phone) contactItems.push(`<span class="contact-item">📞 ${phone}</span>`)
  if (email) contactItems.push(`<span class="contact-item">✉️ ${email}</span>`)
  if (wechat) contactItems.push(`<span class="contact-item">💬 ${wechat}</span>`)

  return `
  <section class="module basic-info">
    <div class="header">
      <h1 class="name">${name}</h1>
      <p class="job-intention">${jobIntention}</p>
    </div>
    <div class="contact-bar">
      ${contactItems.join('\n      ')}
    </div>
  </section>`
}

function generateEducation(content) {
  const school = content.school || ''
  const major = content.major || ''
  const degree = content.degree || ''
  const startDate = content.start_date || ''
  const endDate = content.end_date || ''

  return `
  <section class="module education">
    <div class="timeline-item">
      <div class="timeline-header">
        <h3 class="school">${school}</h3>
        <span class="date-range">${startDate} ~ ${endDate}</span>
      </div>
      <div class="timeline-body">
        <span class="major">${major}</span>
        <span class="degree">${degree}</span>
      </div>
    </div>
  </section>`
}

function generateWorkExperience(content) {
  const company = content.company || ''
  const position = content.position || ''
  const techStack = content.tech_stack || ''
  const responsibilities = Array.isArray(content.responsibilities) ? content.responsibilities : []
  const startDate = content.start_date || ''
  const endDate = content.end_date || ''

  const respItems = responsibilities
    .filter((r) => r.trim())
    .map((r) => `<li>${r}</li>`)
    .join('\n        ')

  return `
  <section class="module work-experience">
    <div class="timeline-item">
      <div class="timeline-header">
        <h3 class="company">${company}</h3>
        <span class="date-range">${startDate} ~ ${endDate}</span>
      </div>
      <div class="timeline-body">
        <p class="position">${position}</p>
        ${techStack ? `<p class="tech-stack"><strong>技术栈：</strong>${techStack}</p>` : ''}
        ${respItems ? `<ul class="responsibilities">\n        ${respItems}\n      </ul>` : ''}
      </div>
    </div>
  </section>`
}

function generateProject(content) {
  const projectName = content.project_name || ''
  const role = content.role || ''
  const startDate = content.start_date || ''
  const endDate = content.end_date || ''
  const techStack = content.tech_stack || ''
  const description = content.description || ''
  const achievements = Array.isArray(content.achievements) ? content.achievements : []

  const achItems = achievements
    .filter((a) => a.trim())
    .map((a) => `<li>${a}</li>`)
    .join('\n        ')

  return `
  <section class="module project">
    <div class="project-card">
      <div class="project-header">
        <h3 class="project-name">${projectName}</h3>
        <span class="date-range">${startDate} ~ ${endDate}</span>
      </div>
      <div class="project-body">
        <p class="role"><strong>角色：</strong>${role}</p>
        ${techStack ? `<p class="tech-stack"><strong>技术栈：</strong>${techStack}</p>` : ''}
        ${description ? `<p class="description">${description}</p>` : ''}
        ${achItems ? `<ul class="achievements">\n        ${achItems}\n      </ul>` : ''}
      </div>
    </div>
  </section>`
}

function generateAward(content) {
  const certificates = Array.isArray(content.certificates) ? content.certificates : []

  const certTags = certificates
    .filter((c) => c.trim())
    .map((c) => `<span class="award-tag">${c}</span>`)
    .join('\n      ')

  return `
  <section class="module award">
    <div class="award-list">
      ${certTags}
    </div>
  </section>`
}

export { generateHtml }
