#!/bin/bash

input(){
    read -r -p "$1 [$2]: " input
    echo "${input:-$2}"                         
}

while true; do
    echo "1. Specify Log Directory"
    echo "2. Days to Store Logs"
    echo "3. Days to Keep Backup Archives"
    echo "4. Archive Logs"
    echo "5. Exit"

    read -r -p "Choose an option [1-5]: " choice

    case $choice in
        1)
            log_dir=$(input "Enter Log Directory" "/var/log")
            if [ ! -d "$log_dir" ]; then
                echo "Error: Enter Valid Directory"
            else
                echo "Log Directory is set to $log_dir"
            fi
            ;;
        2)
            store_days=$(input "Enter number of days to store the logs" "7")
            echo "Logs will be stored for $store_days days"
            ;;
        3)
            days_to_keep_backup=$(input "How many days do you want to keep the backup" "90")
            echo "Backup will be stored for $days_to_keep_backup days"
            ;;
        4)
            if [ -z "$log_dir" ]; then           
                echo "Error: Log Directory not set, please enter log directory first"
            else
                archive_directory="$log_dir/archive"
                sudo mkdir -p "$archive_directory"    
                timestamp=$(date +"%Y%m%d_%H%M%S")  
                archive_file="$archive_directory/logs_archive_$timestamp.tar.gz"
		#find and compress logs older than specified days
                find "$log_dir" -type f -mtime +"$store_days" -print0 | tar -czvf "$archive_file" --null -T -
                #delete log files older than specific number of days
		find "$log_dir" -type f -mtime +"$store_days" -exec rm -f {} \;
                echo "Archive completed: $archive_file"
            fi
            ;;
        5)
            echo "Exit"
            break
            ;;
        *)
            echo "Invalid Option"
            ;;
    esac
done
