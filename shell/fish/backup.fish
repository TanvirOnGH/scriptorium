# Create backups of one or more files
function backup
    if test (count $argv) -eq 0
        echo "Usage: backup <file1> [file2] [file3] ..."
        return 1
    end

    for file_to_backup in $argv
        set backup_file $file_to_backup.bak

        if test -e $file_to_backup
            if test ! -e $backup_file
                cp $file_to_backup $backup_file
                echo "Backup created for $file_to_backup: $backup_file"
            else
                echo "Backup already exists for $file_to_backup, skipping."
            end
        else
            echo "File not found: $file_to_backup"
        end
    end
end
