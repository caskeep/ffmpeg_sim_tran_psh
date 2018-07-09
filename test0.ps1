function TotalLiveFolder([string]$path) {
	Write-Output "";
	Write-Output "###### top level folder name is: $path";
	$fc = new-object -com scripting.filesystemobject
	$folder = $fc.getfolder($path)
	$folder_size_byte = $folder.size
	$folder_size_gb = $folder_size_byte/1024/1024/1024
	$folder_name = $folder.name
	$folder_path = $folder.path
	Write-Output "###### top level folder size is: $folder_size_gb GB";
	Write-Output "###### top level folder name is: $folder_name";
	foreach ($i in $folder.subfolders) {
		$sub_folder_name = $i.name
		$sub_folder_path = $i.path
		Write-Output "###### sub folder path is: $sub_folder_path";
		Write-Output "###### sub folder name is: $sub_folder_name";
		$new_sub_folder_name = $sub_folder_name + "[[done]]"
		$new_sub_folder_path = $folder_path + "\" + $new_sub_folder_name
		Recurse $sub_folder_path $new_sub_folder_path
	}
}
function Recurse([string]$path, [string]$new_path) {
	Write-Output "";
	Write-Output "###### folder name is: $path";
	$fc = new-object -com scripting.filesystemobject
	$folder = $fc.getfolder($path)
	$folder_size_byte = $folder.size
	$folder_size_gb = $folder_size_byte/1024/1024/1024
	Write-Output "###### folder size is: $folder_size_gb GB";
	New-Item -Path "$new_path" -ItemType directory
	foreach ($one_file in $folder.files) {
		ProcessOneFile $one_file $new_path
	}
	foreach ($one_folder in $folder.subfolders) {
		$one_folder_name = $one_folder.name
		$one_folder_path = $one_folder.path
		$new_folder_path = $new_path + "\" + $one_folder_name
		Recurse $one_folder_path $new_folder_path
	}
}
function ProcessOneFile ($one_file, [string]$destination_path) {
	Write-Output "";
	Write-Output "*** file ***";
	$one_file_full_name = $one_file.Name
	Write-Output "file fullname is: $one_file_full_name";
	$one_file_full_path = $path + "\" + $one_file_full_name
	Write-Output "file full path is: $one_file_full_path";
	$one_file_size_byte = $one_file.size
	$one_file_size_mb = $one_file_size_byte/1024/1024
	Write-Output "file size is: $one_file_size_mb MB";
	$one_file_name = 
		[System.IO.Path]::GetFileNameWithoutExtension($one_file_full_name)
	Write-Output "file name is: $one_file_name"
	$one_file_extension = [System.IO.Path]::GetExtension($one_file_full_name)
	Write-Output "file extension is: $one_file_extension"
	$file_type = 0
	If($one_file_extension -eq ".mkv") {
		Write-Output "file type is: video file";
		$file_type = 1
	}
	ElseIf($one_file_extension -eq ".mp4") {
		Write-Output "file type is: video file";
		$file_type = 1
	}
	else {
		Write-Output "file type is: else file";
		$file_type = 3
	}
	Write-Output "file type code is: $file_type"
	if($file_type -eq 1)
	{
		Write-Output "not video file, convert and move it"
		$new_file_name = $one_file_name
		$new_file_extension = ".mp4"
		$new_file_full_name = $new_file_name + $new_file_extension
		$new_file_full_path = $destination_path + "\" +  $new_file_full_name
		$cmd = '.\ffmpeg.exe'
		$arg1 = '-i'
		$arg2 = '"' + $one_file_full_path + '"'
		$arg3 = '-c:v'
		$arg4 = 'hevc_nvenc'
		$arg5 = '-profile:v'
		$arg6 = 'main10'
		$arg7 = '-rc'
		$arg8 = 'vbr_hq'
		$arg9 = '"' + $new_file_full_path + '"'
		$full_cmd = $cmd + " " + $arg1 + " " + $arg2 + " " + $arg3 + " " + $arg4 + " " + $arg5 + " " + $arg6 + " " + $arg7 + " " + $arg8 + " " + $arg9
		Write-Output "full_cmd is $full_cmd";
		& $cmd $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9
	# } elseif ($file_type -eq 2) {
	# 	$new_file_name = $one_file_name + "[[origin]]"
	# 	$new_file_extension = ".mp4"
	# 	$new_file_full_name = $new_file_name + $new_file_extension
	# 	$new_file_full_path = $path + "\" +  $new_file_full_name
	# 	Rename-Item -LiteralPath "$one_file_full_path" -NewName "$new_file_full_name"
	# 	$cmd = '.\ffmpeg.exe'
	# 	$arg1 = '-i'
	# 	$arg2 = "$new_file_full_path"
	# 	$arg3 = '-c:v'
	# 	$arg4 = 'hevc_nvenc'
	# 	$arg5 = '-profile:v'
	# 	$arg6 = 'main10'
	# 	$arg7 = '-rc'
	# 	$arg8 = 'vbr_hq'
	# 	$arg9 = "$one_file_full_path"
	# 	$full_cmd = $cmd + " " + $arg1 + " " + $arg2 + " " + $arg3 + " " + $arg4 + " " + $arg5 + " " + $arg6 + " " + $arg7 + " " + $arg8 + " " + $arg9
	# 	Write-Output "full_cmd is $full_cmd";
	# 	# & $cmd $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9
	} else {
		Write-Output "not video file, just move it"
		$new_file_full_name = $one_file_full_name
		$new_file_full_path = $destination_path + "\" +  $new_file_full_name
		$full_cmd = "Move-Item -LiteralPath $one_file_full_path -Destination $new_file_full_path"
		Write-Output "full_cmd is $full_cmd";
		Move-Item -LiteralPath "$one_file_full_path" -Destination "$new_file_full_path"
	}
}
function ConvertVideoFiles ($File) {
	Write-Output "ConvertVideoFiles";
}
TotalLiveFolder("G:\ing")
