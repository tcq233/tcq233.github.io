import subprocess
import sys

def install_packages():
    packages = [
        "Flask>=2.0.0",
        "yt-dlp>=2025.6.30"
    ]
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", *packages])
        print("依赖安装完成！")
    except subprocess.CalledProcessError as e:
        print(f"安装依赖失败: {e}")
        sys.exit(1)

install_packages()

import os
import tempfile
from flask import Flask, request, render_template_string, redirect, url_for, flash, send_file
import yt_dlp
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'

app.config['MAX_CONTENT_LENGTH'] = 300 * 1024  # 300KB上传限制
ALLOWED_EXTENSIONS = {'txt'}

parsed_results = {}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_video_info(youtube_url, cookiefile=None):
    ydl_opts = {
        'quiet': True,
        'noplaylist': True,
    }
    if cookiefile:
        ydl_opts['cookiefile'] = cookiefile
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(youtube_url, download=False)
    return info

def get_best_video_url(youtube_url, cookiefile=None):
    ydl_opts = {
        'quiet': True,
        'noplaylist': True,
        'format': 'bestvideo+bestaudio/best',
    }
    if cookiefile:
        ydl_opts['cookiefile'] = cookiefile
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(youtube_url, download=False)
        best_url = info.get('url')
        if not best_url:
            for f in info.get('formats', []):
                if f.get('vcodec') != 'none' and f.get('acodec') != 'none':
                    best_url = f.get('url')
                    break
        return best_url

INPUT_PAGE = '''
<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8" />
<link rel="shortcut icon" href="https://github.githubassets.com/favicons/favicon.svg">
<title>YouTube-视频预览</title>
<style>
 body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
    Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
  background: #f0f4f8;
  margin: 0;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #333;
  padding: 20px;
  box-sizing: border-box;
}

.container {
  background: #fff;
  padding: 40px 48px;
  border-radius: 16px;
  box-shadow: 0 12px 30px rgb(0 0 0 / 0.1);
  width: 100%;
  max-width: 700px;
  box-sizing: border-box;
  text-align: center;
}

h1 {
  font-weight: 700;
  font-size: 28px;
  margin-bottom: 40px;
  user-select: none;
  color: #222;
}

form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

label {
  font-size: 16px;
  color: #555;
  user-select: none;
  text-align: left;
  margin: 0 auto;
  max-width: 600px;
}

input[type=file],
textarea,
input[type=text] {
  margin: 0 auto;
  font-size: 16px;
  max-width: 600px;
  width: 90%;
  padding: 8px 12px;
  border: 2px solid #3b82f6;
  border-radius: 8px;
  box-shadow: inset 0 4px 12px rgb(0 0 0 / 0.1);
  outline: none;
  resize: vertical;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
  box-sizing: border-box;
}

input[type=file]:focus,
textarea:focus,
input[type=text]:focus {
  border-color: #2563eb;
  box-shadow: 0 0 14px #2563eb;
}

textarea {
  height: 160px;
  min-height: 120px;
  max-height: 300px;
  line-height: 1.5;
}

button {
  width: 220px;
  padding: 16px 0;
  margin: 0 auto;
  font-size: 22px;
  font-weight: 700;
  color: white;
  background: linear-gradient(90deg, #3b82f6 0%, #2563eb 100%);
  border: none;
  border-radius: 14px;
  cursor: pointer;
  box-shadow: 0 6px 18px rgb(59 130 246 / 0.6);
  transition: background 0.3s ease, box-shadow 0.3s ease;
  user-select: none;
}

button:hover {
  background: linear-gradient(90deg, #2563eb 0%, #1e40af 100%);
  box-shadow: 0 8px 22px rgb(37 99 235 / 0.7);
}

.error {
  margin-top: 24px;
  color: #dc2626;
  font-weight: 600;
  user-select: none;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
  text-align: center;
}

a.download-link {
  display: block;
  margin-top: 30px;
  font-size: 18px;
  color: #3b82f6;
  text-decoration: none;
}

a.download-link:hover {
  text-decoration: underline;
}

/* 响应式适配 */
@media (max-width: 768px) {
  .container {
    padding: 30px 24px;
  }
  h1 {
    font-size: 24px;
    margin-bottom: 30px;
  }
  button {
    width: 100%;
    font-size: 20px;
    padding: 14px 0;
  }
  input[type=file],
  textarea,
  input[type=text] {
    width: 100%;
    max-width: none;
  }
  label {
    max-width: none;
  }
  a.download-link {
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  h1 {
    font-size: 20px;
    margin-bottom: 20px;
  }
  button {
    font-size: 18px;
    padding: 12px 0;
  }
}

</style>
</head>
<body>
  <div class="container">
    <form method="post" enctype="multipart/form-data">
      <label>
上传<a href="https://chrome.google.com/webstore/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc" target="_blank" style="margin-left:8px; font-size:14px; color:#3b82f6; text-decoration:none;">Cookie</a> 文件（仅限txt，最大100K，选填）：</label>

      <input type="file" name="cookiefile" accept=".txt" />

      <label>或者直接在这里输入视频链接（多行，每行一个链接）：</label>
      <textarea name="linktextarea" placeholder="https://www.youtube.com/watch?v=..." ></textarea>
      
      <button type="submit">开始解析链接</button>
<div style="display: flex; justify-content: center; gap: 24px; margin-top: 12px;">
  <a href="https://github.com/tcq20256/yt-dlp-youtube-web" 
     style="font-size:14px; color:#3b82f6; text-decoration:none; align-self: center;">
    项目地址
  </a>
  <a href="https://cloud.tencent.com/act/cps/redirect?redirect=33387&cps_key=615609c54e8bcced8b02c202a43b5570" target="_blank"
     style="font-size:14px; color:#3b82f6; text-decoration:none; align-self: center;">
    域名注册
  </a>
</div>

    </form>
    {% with messages = get_flashed_messages() %}
      {% if messages %}
        <div class="error">{{ messages[0] }}</div>
      {% endif %}
    {% endwith %}
    {% if download_url %}
      <a href="{{ download_url }}" class="download-link" download>⬇️ 点击这里下载解析结果TXT文件</a>
    {% endif %}
  </div>
</body>
</html>
'''

RESULT_PAGE = '''
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>解析结果 - {{ info.title }}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
        Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
      background: #f5f7fa;
      margin: 20px;
      color: #333;
      text-align: center;
    }
    h1 {
      font-weight: 700;
      font-size: 26px;
      margin-bottom: 20px;
    }
    .container {
      max-width: 720px;
      margin: 0 auto;
      background: #fff;
      padding: 24px 28px;
      border-radius: 12px;
      box-shadow: 0 10px 30px rgb(0 0 0 / 0.08);
    }
    h2 {
      font-weight: 700;
      font-size: 20px;
      margin-bottom: 16px;
      word-break: break-word;
    }
    img {
      max-width: 320px;
      border-radius: 12px;
      margin-bottom: 20px;
      box-shadow: 0 6px 12px rgb(0 0 0 / 0.08);
    }
    .btn-grid {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 14px 18px;
      margin-top: 20px;
    }
    .download-btn {
      background-color: #3b82f6;
      color: white;
      border-radius: 10px;
      padding: 14px 22px;
      font-size: 15px;
      font-weight: 600;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      box-shadow: 0 3px 10px rgb(59 130 246 / 0.45);
      transition: background-color 0.3s ease;
      user-select: none;
      cursor: pointer;
      white-space: nowrap;
      border: none;
      min-width: 150px;
      justify-content: center;
    }
    .download-btn:hover {
      background-color: #2563eb;
    }
    .no-audio-icon {
      font-size: 16px;
      color: #f87171;
      user-select: none;
    }
    a.back-link {
      display: inline-block;
      margin-top: 20px;
      font-size: 14px;
      color: #3b82f6;
      cursor: pointer;
      text-decoration: none;
    }
    a.back-link:hover {
      text-decoration: underline;
    }
    @media (max-width: 600px) {
      img {
        max-width: 100%;
      }
      .btn-grid {
        justify-content: center;
      }
      .download-btn {
        min-width: 120px;
        font-size: 13px;
        padding: 10px 16px;
      }
    }
  </style>
</head>
<body>
  <h1>解析结果</h1>
  <div class="container">
    <h2>{{ info.title }}</h2>
    <img src="{{ info.thumbnail }}" alt="视频封面" />
    <div>
      <button class="download-btn" onclick="window.open('{{ info.url }}', '_blank')">
        ⬇️ 下载视频（自动选择最佳画质）
      </button>
      <button class="download-btn" onclick="window.open('{{ info.thumbnail }}', '_blank')">
        🖼️ 下载封面
      </button>
    </div>

    <h3 style="margin-top: 30px;">更多视频分辨率下载选项</h3>
    <div class="btn-grid">
      {% for f in formats %}
        {% if f.vcodec != 'none' %}
          <a class="download-btn" href="{{ f.url }}" target="_blank" download>
            {{ f.format_note or f.format }} ({{ f.ext }})
            {% if f.filesize %} - {{ (f.filesize / 1024 / 1024) | round(2) }}MB{% endif %}
            {% if f.acodec == 'none' %}
              <span class="no-audio-icon" title="无声音轨">🔇</span>
            {% endif %}
          </a>
        {% endif %}
      {% endfor %}
    </div>

    <h3 style="margin-top: 30px;">所有音频格式</h3>
    <div class="btn-grid">
      {% for f in formats %}
        {% if f.vcodec == 'none' and f.acodec != 'none' %}
          <a class="download-btn" href="{{ f.url }}" target="_blank" download>
            {{ f.format_note or f.format }} ({{ f.ext }})
            {% if f.filesize %} - {{ (f.filesize / 1024 / 1024) | round(2) }}MB{% endif %}
          </a>
        {% endif %}
      {% endfor %}
    </div>

    <a href="{{ url_for('index') }}" class="back-link">← 返回首页</a>
  </div>
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def index():
    error = None
    url = ''
    download_url = None

    if request.method == 'POST':
        cookie_path = None
        cookiefile = request.files.get('cookiefile')
        if cookiefile and cookiefile.filename != '':
            if not allowed_file(cookiefile.filename):
                flash('只允许上传 txt 格式的 cookie 文件。')
                return render_template_string(INPUT_PAGE, error=None, url='')
            filename = secure_filename(cookiefile.filename)
            with tempfile.NamedTemporaryFile(delete=False) as tmp:
                cookiefile.save(tmp.name)
                cookie_path = tmp.name

        linkfile = request.files.get('linkfile')
        if linkfile and linkfile.filename != '':
            # 批量上传链接txt，批量解析，生成下载文件
            if not allowed_file(linkfile.filename):
                flash('只允许上传 txt 格式的链接文件。')
                if cookie_path and os.path.exists(cookie_path):
                    os.remove(cookie_path)
                return render_template_string(INPUT_PAGE, error=None, url='')
            try:
                content = linkfile.stream.read().decode('utf-8')
                link_lines = [line.strip() for line in content.splitlines() if line.strip()]
            except Exception:
                flash('读取链接文件失败，请确认编码为UTF-8')
                if cookie_path and os.path.exists(cookie_path):
                    os.remove(cookie_path)
                return render_template_string(INPUT_PAGE, error=None, url='')

            if not link_lines:
                flash('上传的链接文件为空或无有效链接。')
                if cookie_path and os.path.exists(cookie_path):
                    os.remove(cookie_path)
                return render_template_string(INPUT_PAGE, error=None, url='')

            results = []
            for url_line in link_lines:
                try:
                    video_url = get_best_video_url(url_line, cookiefile=cookie_path)
                    if video_url:
                        results.append(f"{url_line} {video_url}")
                    else:
                        results.append(f"解析失败 {url_line}")
                except Exception as e:
                    results.append(f"解析异常 {url_line} 错误: {str(e)}")

            if cookie_path and os.path.exists(cookie_path):
                os.remove(cookie_path)

            tmp = tempfile.NamedTemporaryFile(delete=False, mode='w', encoding='utf-8', suffix='.txt')
            tmp.write('\n'.join(results))
            tmp.close()

            file_id = os.path.basename(tmp.name)
            parsed_results[file_id] = tmp.name
            download_url = url_for('download_file', file_id=file_id)

            return render_template_string(INPUT_PAGE, download_url=download_url, error=None, url='')

        else:
            # 没上传路径txt，走单链接解析（文本框）
            url = request.form.get('linktextarea', '').strip()
            if not url:
                flash('请输入视频链接或上传链接文件。')
                if cookie_path and os.path.exists(cookie_path):
                    os.remove(cookie_path)
                return render_template_string(INPUT_PAGE, error=None, url='')

            try:
                data = get_video_info(url, cookiefile=cookie_path)
                parsed_results[url] = data
                if cookie_path and os.path.exists(cookie_path):
                    os.remove(cookie_path)
                return redirect(url_for('result', video_url=url))
            except Exception as e:
                error = f"解析失败: {e}"
                if cookie_path and os.path.exists(cookie_path):
                    os.remove(cookie_path)

    return render_template_string(INPUT_PAGE, error=error, url=url, download_url=download_url)


@app.route('/result')
def result():
    video_url = request.args.get('video_url')
    data = parsed_results.get(video_url)
    if not data:
        return redirect(url_for('index'))
    return render_template_string(RESULT_PAGE, info=data, formats=data.get('formats', []))


@app.route('/download/<file_id>')
def download_file(file_id):
    filepath = parsed_results.get(file_id)
    if filepath and os.path.exists(filepath):
        response = send_file(filepath, as_attachment=True, download_name='parsed_results.txt')
        def cleanup(response):
            try:
                os.remove(filepath)
                parsed_results.pop(file_id, None)
            except Exception:
                pass
            return response
        response.call_on_close(cleanup)
        return response
    else:
        flash("下载文件不存在或已过期")
        return redirect(url_for('index'))


if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
