use tauri_plugin_dialog::{DialogExt, FileDialogBuilder};
use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex};
use std::path::PathBuf;

#[derive(Debug, Serialize, Deserialize)]
pub struct FileInfo {
    pub path: String,
    pub name: String,
    pub size: Option<u64>,
}

// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
async fn open_file_dialog(
    window: tauri::Window,
    title: Option<String>,
    default_path: Option<String>,
    filters: Option<Vec<(String, Vec<String>)>>,
) -> Result<Option<FileInfo>, String> {
    let dialog = window.dialog().clone();
    let mut builder = FileDialogBuilder::new(dialog);
    builder = builder.set_title(title.unwrap_or_else(|| "Select File".to_string()));

    // 设置默认目录
    if let Some(path) = default_path {
        let default_dir = PathBuf::from(&path);
        if default_dir.exists() {
            builder = builder.set_directory(&default_dir);
        }
    }

    // Apply filters if provided
    if let Some(filter_list) = filters {
        for (name, extensions) in filter_list {
            let ext_refs: Vec<&str> = extensions.iter().map(|s| s.as_str()).collect();
            builder = builder.add_filter(name, &ext_refs);
        }
    }

    let result = Arc::new(Mutex::new(None));
    let result_clone = Arc::clone(&result);

    builder.pick_file(move |file_path| {
        *result_clone.lock().unwrap() = file_path;
    });

    // Simple wait loop - in production you might want a better async approach
    loop {
        if let Ok(guard) = result.lock() {
            if guard.is_some() {
                let path = guard.clone();
                drop(guard);
                
                match path {
                    Some(path) => {
                        // Convert FilePath to PathBuf
                        if let Some(path_ref) = path.as_path() {
                            let path_buf = PathBuf::from(path_ref);
                            let name = path_buf.file_name()
                                .and_then(|n| n.to_str())
                                .unwrap_or("Unknown")
                                .to_string();
                            
                            let size = std::fs::metadata(&path_buf)
                                .ok()
                                .map(|metadata| metadata.len());

                            return Ok(Some(FileInfo {
                                path: path_ref.to_string_lossy().to_string(),
                                name,
                                size,
                            }));
                        }
                        return Ok(None);
                    }
                    None => return Ok(None),
                }
            }
        }
        tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![
            greet,
            open_file_dialog
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}