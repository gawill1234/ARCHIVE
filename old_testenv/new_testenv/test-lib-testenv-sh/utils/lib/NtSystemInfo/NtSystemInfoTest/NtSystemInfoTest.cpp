// Written by Zoltan Csizmadia, zoltan_csizmadia@yahoo.com
// For companies(Austin,TX): If you would like to get my resume, send an email.
//
// The source is free, but if you want to use it, mention my name and e-mail address
//
//////////////////////////////////////////////////////////////////////////////////////
//
// NtSystemInfoTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <tchar.h>
#include <stdio.h>
#include "SystemInfo.h"

// Show process list
void ListProcesses( DWORD processID )
{
	DWORD pID;
	CString name;
	SystemProcessInformation::SYSTEM_PROCESS_INFORMATION* p = NULL;

	// Create process info object
	SystemProcessInformation pi( TRUE );
	
	if ( pi.m_ProcessInfos.GetStartPosition() == NULL )
	{
		_tprintf( _T("No process information\n") );
		return;
	}

	_tprintf( _T("%-6s  %s\n"), _T("PID"), _T("Name") );
	_tprintf( _T("----------------------------------------\n") );
	
	// Iterating through the processes
	for ( POSITION pos = pi.m_ProcessInfos.GetStartPosition(); pos != NULL; )
	{
		pi.m_ProcessInfos.GetNextAssoc( pos, pID, p ); 

		// Filtering by process ID
		if ( processID == (DWORD)-1 || pID == processID )
		{
			SystemInfoUtils::Unicode2CString( &p->usName, name );
		
			_tprintf( _T("0x%04X  %s\n"), pID, name );
		}
	}
}

void ListThreads( DWORD processID )
{
	SystemThreadInformation ti( processID, TRUE );

	if ( ti.m_ThreadInfos.GetHeadPosition() == NULL )
	{
		_tprintf( _T("No thread information\n") );
		return;
	}

	_tprintf( _T("%-6s  %s\n"), _T("PID"), _T("TID") );
	_tprintf( _T("---------------------------\n") );

	// Iterating through the threads
	for ( POSITION pos = ti.m_ThreadInfos.GetHeadPosition(); pos != NULL; )
	{
		SystemThreadInformation::THREAD_INFORMATION& t = ti.m_ThreadInfos.GetNext(pos);
		
		_tprintf( _T("0x%04X  0x%04X\n"), 
					t.ProcessId,
					t.ThreadId );
	}
}

void ListModules( DWORD processID, LPCTSTR lpFilter )
{
	BOOL show = TRUE;
	SystemModuleInformation mi( processID, TRUE );

	if ( mi.m_ModuleInfos.GetHeadPosition() == NULL )
	{
		_tprintf( _T("No module information\n") );
		return;
	}
	
	_tprintf( _T("%-6s  %-10s  %s\n"), _T("PID"), _T("Address"), _T("Path") );
	_tprintf( _T("----------------------------------------------------------\n") );

	// Iterating through the modules
	for ( POSITION pos = mi.m_ModuleInfos.GetHeadPosition(); pos != NULL; )
	{
		SystemModuleInformation::MODULE_INFO& m = mi.m_ModuleInfos.GetNext(pos);

		// Module name filtering
		if ( lpFilter == NULL )
			show = TRUE;
		else
		{
			if ( lpFilter[0] == _T('\0') )
				show = TRUE;
			else
			{
				TCHAR drive[_MAX_DRIVE];
				TCHAR dir[_MAX_DIR];
				TCHAR fname[_MAX_FNAME];
				TCHAR ext[_MAX_EXT];
				TCHAR fnameandext[_MAX_PATH];

				_tsplitpath( m.FullPath, drive, dir, fname, ext );

				_tcscpy( fnameandext, fname );
				_tcscat( fnameandext, ext );
   
				show = _tcsicmp( fnameandext, lpFilter ) == 0;
			}
		}
		
		if ( show )
			_tprintf( _T("0x%04X  0x%08X  %s\n"), 
				m.ProcessId, 
				m.Handle, 
				m.FullPath );
	}
}

void ListWindows( DWORD processID )
{
	SystemWindowInformation wi( processID, TRUE );

	if ( wi.m_WindowInfos.GetHeadPosition() == NULL )
	{
		_tprintf( _T("No window information\n") );
		return;
	}
	
	_tprintf( _T("%-6s  %-10s  %s\n"), _T("PID"), _T("Handle"), _T("Caption") );
	_tprintf( _T("----------------------------------------------------------\n") );

	// Iterating through the windows
	for ( POSITION pos = wi.m_WindowInfos.GetHeadPosition(); pos != NULL; )
	{
		SystemWindowInformation::WINDOW_INFO& w = wi.m_WindowInfos.GetNext(pos);
		
		_tprintf( _T("0x%04X  0x%08X  %s\n"), 
				w.ProcessId, 
				w.hWnd, 
				w.Caption );
	}
}

void ListHandles( DWORD processID, LPCTSTR lpFilter )
{
	CString processName;
	SystemProcessInformation pi;
	SystemProcessInformation::SYSTEM_PROCESS_INFORMATION* pPi;
	SystemHandleInformation hi( processID, FALSE );
	hi.SetFilter( lpFilter, TRUE );

	if ( hi.m_HandleInfos.GetHeadPosition() == NULL )
	{
		_tprintf( _T("No handle information\n") );
		return;
	}

	if ( !pi.Refresh() )
	{
		_tprintf( _T("SystemProcessInformation::Refresh() failed.\n") );
		return;
	}
	
	_tprintf( _T("%-6s  %-10s  %-10s  %s\n"), _T("PID"), _T("Handle"), _T("Type"), _T("Name") );
	_tprintf( _T("----------------------------------------------------------\n") );

	CString type;
	CString name;
	CString fsPath;
	
	// Iterating through the handles
	for ( POSITION pos = hi.m_HandleInfos.GetHeadPosition(); pos != NULL; )
	{
		SystemHandleInformation::SYSTEM_HANDLE& h = hi.m_HandleInfos.GetNext(pos);

		if ( !pi.m_ProcessInfos.Lookup( h.ProcessID, pPi ) )
			continue;

		if ( pPi == NULL )
			continue;

		//Get the process name
		SystemInfoUtils::Unicode2CString( &pPi->usName, processName );

		//NT4 Stupid thing if it is the services.exe and I call GetName :((
		if ( INtDll::dwNTMajorVersion == 4 && _tcsicmp( processName, _T("services.exe" ) ) == 0 )
			name = "";
		else
			hi.GetName( (HANDLE)h.HandleNumber, name, h.ProcessID );

		hi.GetTypeToken( (HANDLE)h.HandleNumber, type, h.ProcessID  );
		

		if ( h.HandleType == SystemHandleInformation::OB_TYPE_FILE )
		{
			if ( SystemInfoUtils::GetFsFileName( name, fsPath ) )
				name = fsPath;
		}
		
		_tprintf( _T("0x%04X  0x%08X  %-10s  %s\n"), 
				h.ProcessID, 
				h.HandleNumber, 
				type,
				name );
	}
}

// Enable the SeDebugPrivilege
void EnableDebugPriv( void )
{
	HANDLE hToken;
	LUID sedebugnameValue;
	TOKEN_PRIVILEGES tkp;

	// enable the SeDebugPrivilege
	if ( ! OpenProcessToken( GetCurrentProcess(),
		TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken ) )
	{
		_tprintf( _T("OpenProcessToken() failed, Error = %d SeDebugPrivilege is not available.\n") , GetLastError() );
		return;
	}

	if ( ! LookupPrivilegeValue( NULL, SE_DEBUG_NAME, &sedebugnameValue ) )
	{
		_tprintf( _T("LookupPrivilegeValue() failed, Error = %d SeDebugPrivilege is not available.\n"), GetLastError() );
		CloseHandle( hToken );
		return;
	}

	tkp.PrivilegeCount = 1;
	tkp.Privileges[0].Luid = sedebugnameValue;
	tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

	if ( ! AdjustTokenPrivileges( hToken, FALSE, &tkp, sizeof tkp, NULL, NULL ) )
		_tprintf( _T("AdjustTokenPrivileges() failed, Error = %d SeDebugPrivilege is not available.\n"), GetLastError() );
		
	CloseHandle( hToken );
}

// Usage
void ShowUsage()
{
	_tprintf( _T("NtSysInfo for www.codeguru.com\n") );
	_tprintf( _T("Written by Zoltan Csizmadia, zoltan_csizmadia@yahoo.com \n") );
	_tprintf( _T("\n") );
	_tprintf( _T("Usage: NtSysInfo.exe [/H[type]|/M[dllname]|/P|/T|/W] [processId]}\n") );
	_tprintf( _T("\n") );
	_tprintf( _T("          /H            Handle list. Can be filtered by \"type\"\n") );
	_tprintf( _T("                             type: File, Thread, Semaphore, Process, Event,...\n") );
	_tprintf( _T("          /M            Module list. Can be filtered by \"dllname\"\n") );
	_tprintf( _T("          /P            Process list (processId not used)\n") );
	_tprintf( _T("          /T            Thread list\n") );
	_tprintf( _T("          /W            Window list\n") );
	_tprintf( _T("          processId     Process ID, dec. or 0x??? (-1 = every process, default)\n") );
	_tprintf( _T("\n") );
	_tprintf( _T("Examples:\n") );
	_tprintf( _T("          NtSysInfo.exe /HFile 651\n") );
	_tprintf( _T("          NtSysInfo.exe /H 1248\n") );
	_tprintf( _T("          NtSysInfo.exe /Mkernel32.dll\n") );
	_tprintf( _T("          NtSysInfo.exe /P\n") );
	_tprintf( _T("          NtSysInfo.exe /W\n") );
	_tprintf( _T("          NtSysInfo.exe /W 1215\n") );
}

int _tmain(int argc, TCHAR** argv)
{
	int rc = 0;

	if ( argc <= 1 )
	{
		// Show Usage
		ShowUsage();
		return 1;
	}

	if ( argv[1][0] != _T('/') && argv[1][0] != _T('-') )
	{
		// Show Usage
		ShowUsage();
		return 1;
	}

	TCHAR command = argv[1][1];
	LONG processID;
	
	if ( argv[2] == NULL )
		processID = -1;
	else
	{
		if ( _tcsnicmp( argv[2], _T("0x"), 2 ) == 0 )
			_stscanf( argv[2] + 2, "%x", &processID );
		else
			processID = atoi(argv[2]);
	}

	EnableDebugPriv();

	// Let's work
	switch( command )
	{
	case _T('p'):
	case _T('P'):
		ListProcesses( processID );
		break;

	case _T('m'):
	case _T('M'):
		ListModules( processID, argv[1] + 2 );
		break;

	case _T('w'):
	case _T('W'):
		ListWindows( processID );
		break;

	case _T('t'):
	case _T('T'):
		ListThreads( processID );
		break;

	case _T('h'):
	case _T('H'):
		ListHandles( processID, argv[1] + 2 );
		break;
		
	default:
		ShowUsage();
		rc = 1;
	}

	return rc;
}
