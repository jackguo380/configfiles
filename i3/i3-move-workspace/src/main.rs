//!
//! A small program to move a i3 workspace
//! to the currently focused display.
//!

extern crate i3ipc;

use std::string::String;
use i3ipc::I3Connection;

fn main() {
    let mut args = std::env::args();

    if args.len() != 2 {
        eprintln!("Usage: i3-move-workspace <workspace>");
        std::process::exit(1);
    }

    let workspace_to_move = args.nth(1).unwrap();

    let mut i3 = I3Connection::connect().expect("Failed to connect to i3");

    let workspaces = i3.get_workspaces().expect("Failed to get i3 workspaces");

    for workspace in workspaces.workspaces {
        if workspace.focused {
            let mut result = i3.run_command(&format!("[workspace={}] move workspace to {}",
                    workspace_to_move, workspace.output)).expect("Failed to move workspace");

            assert_eq!(result.outcomes.len(), 1, "Unexpected number of outputs");

            if !result.outcomes[0].success {
                eprintln!("Failed to move workspace {}: {}", workspace_to_move,
                    result.outcomes[0].error.get_or_insert(String::default()));
                std::process::exit(1);
            }

            std::process::exit(0);
        }
    }

    panic!("Cannot find focused workspace!");
}
