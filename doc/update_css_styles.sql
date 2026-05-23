-- Update CSS styles to support photo layout (avatar fixed at top-right, limited size)
-- Run this after the schema.sql has been applied

UPDATE `css_style` SET `css_content` = ':root {
    --primary: #255deb;
    --primary-light: #dbeafe;
    --dark: #1e293b;
    --gray: #64748b;
    --light-gray: #f1f5f9;
    --white: #ffffff;
    --border: #e2e8f0;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: ''Inter'', sans-serif;
    background-color: #fafafa;
    color: var(--dark);
    line-height: 1.6;
    padding: 2rem;
}

.resume {
    max-width: 960px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.08);
    overflow: hidden;
}

header {
    background: linear-gradient(135deg, var(--primary), #1d4ed8);
    color: var(--white);
    padding: 2.5rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1.5rem;
    position: relative;
}

.header-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.avatar {
    width: 100px;
    height: 130px;
    object-fit: cover;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    flex-shrink: 0;
}

.job-intention {
    font-size: 1.1rem;
    font-weight: 500;
    opacity: 0.9;
}

.contact-info {
    font-size: 0.9rem;
    opacity: 0.85;
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
}

.contact-info a { color: var(--white); text-decoration: underline; }

.summary {
    font-size: 0.95rem;
    opacity: 0.8;
    line-height: 1.5;
}

@media (max-width: 768px) {
    header { flex-direction: column-reverse; align-items: center; }
    .avatar { width: 80px; height: 100px; }
    .contact-info { flex-direction: column; gap: 0.5rem; }
}

.section { padding: 2rem; border-bottom: 1px solid var(--border); }
.section:last-child { border-bottom: none; }

.section-title {
    font-size: 1.375rem;
    font-weight: 600;
    color: var(--primary);
    margin-bottom: 1.25rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid var(--primary-light);
}

.timeline-item { margin-bottom: 1.75rem; }
.timeline-header { display: flex; justify-content: space-between; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.5rem; }
.company, .school { font-weight: 600; font-size: 1.125rem; }
.position, .major { font-weight: 500; color: var(--gray); }

.date {
    background: var(--primary-light);
    color: var(--primary);
    padding: 0.25rem 0.5rem;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 500;
    white-space: nowrap;
}

.description { margin-top: 0.75rem; padding-left: 1rem; border-left: 3px solid var(--primary-light); }
.description li { margin-bottom: 0.5rem; position: relative; padding-left: 1.25rem; }
.description li:before { content: ""; color: var(--primary); font-weight: bold; position: absolute; left: 0; top: 0; }

.certificate-tag {
    background: var(--primary-light);
    color: var(--primary);
    padding: 0.375rem 0.75rem;
    border-radius: 20px;
    font-size: 0.9rem;
    font-weight: 500;
    display: inline-block;
    margin: 0.25rem;
}

.project {
    background: var(--light-gray);
    border-radius: 8px;
    padding: 1.25rem;
    margin-bottom: 1.5rem;
}

.project-title { font-weight: 600; font-size: 1.125rem; margin-bottom: 0.5rem; }

@media (max-width: 768px) {
    body { padding: 1rem; }
    .contact-info { flex-direction: column; gap: 0.75rem; }
}'
WHERE `id` = 1;

UPDATE `css_style` SET `css_content` = ':root {
    --primary: #7c3aed;
    --primary-light: #ede9fe;
    --secondary: #ec4899;
    --dark: #1f2937;
    --gray: #6b7280;
    --light-gray: #f9fafb;
    --white: #ffffff;
    --border: #e5e7eb;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: ''Noto Sans SC'', sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 2rem;
}

.resume {
    max-width: 960px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 20px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.15);
}

header {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: var(--white);
    padding: 3rem 2rem;
    border-radius: 20px 20px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1.5rem;
    position: relative;
}

.header-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.avatar {
    width: 100px;
    height: 130px;
    object-fit: cover;
    border-radius: 12px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.2);
    flex-shrink: 0;
}

.job-intention {
    font-size: 1.1rem;
    font-weight: 500;
    opacity: 0.9;
}

.contact-info {
    font-size: 0.9rem;
    opacity: 0.85;
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
}

.contact-info a { color: var(--white); text-decoration: underline; }

.summary {
    font-size: 0.95rem;
    opacity: 0.8;
    line-height: 1.5;
}

.section { padding: 2.5rem 2rem; border-bottom: 1px dashed var(--border); }

.section-title {
    font-size: 1.5rem;
    font-weight: 700;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin-bottom: 1.5rem;
}

.timeline-item { padding: 1.5rem; border-left: 4px solid var(--primary); margin-bottom: 1.5rem; background: var(--light-gray); border-radius: 0 12px 12px 0; }

.date {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: var(--white);
    padding: 0.5rem 1rem;
    border-radius: 25px;
    font-size: 0.8rem;
}

.certificate-tag {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: var(--white);
    padding: 0.5rem 1rem;
    border-radius: 25px;
    font-size: 0.85rem;
    margin: 0.25rem;
    display: inline-block;
}'
WHERE `id` = 2;

UPDATE `css_style` SET `css_content` = ':root {
    --primary: #000000;
    --dark: #111827;
    --gray: #4b5563;
    --light-gray: #f3f4f6;
    --white: #ffffff;
    --border: #d1d5db;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: ''Times New Roman'', ''Noto Serif SC'', serif;
    background-color: var(--white);
    padding: 0;
    color: var(--dark);
}

.resume {
    max-width: 210mm;
    margin: 0 auto;
    padding: 2rem 3rem;
}

header {
    text-align: center;
    padding: 2rem 0;
    border-bottom: 2px solid var(--primary);
    margin-bottom: 1.5rem;
    position: relative;
}

.header-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
    padding-right: 120px;
}

.avatar {
    position: absolute;
    top: 0;
    right: 0;
    width: 100px;
    height: 130px;
    object-fit: cover;
    border-radius: 4px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.name { font-size: 2rem; font-weight: bold; letter-spacing: 0.1em; }

.job-intention { font-size: 1.1rem; font-weight: 500; color: var(--gray); }

.contact-info {
    display: flex;
    justify-content: center;
    gap: 2rem;
    margin-top: 1rem;
    font-size: 0.9rem;
}

.summary {
    font-size: 0.95rem;
    color: var(--gray);
    line-height: 1.5;
    margin-top: 0.5rem;
}

@media (max-width: 768px) {
    .header-content { padding-right: 0; }
    .avatar { position: static; margin: 1rem auto; }
}

.section { padding: 1.5rem 0; }

.section-title {
    font-size: 1.25rem;
    font-weight: bold;
    text-transform: uppercase;
    border-bottom: 1px solid var(--primary);
    padding-bottom: 0.25rem;
    margin-bottom: 1rem;
}

.timeline-item { margin-bottom: 1rem; }
.timeline-header { display: flex; justify-content: space-between; margin-bottom: 0.25rem; }

.date { font-size: 0.85rem; color: var(--gray); }

.certificate-tag {
    background: var(--light-gray);
    padding: 0.25rem 0.5rem;
    border: 1px solid var(--border);
    font-size: 0.85rem;
    display: inline-block;
    margin: 0.25rem;
}

.project { margin-bottom: 1rem; }
.project-title { font-weight: bold; margin-bottom: 0.25rem; }

.description { margin-top: 0.5rem; }
.description li { margin-bottom: 0.25rem; }'
WHERE `id` = 3;
