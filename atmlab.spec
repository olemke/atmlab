Summary: Helper functions for ARTS interaction with Matlab
Name:    atmlab
Version: 0.1.66
Release: 1ole
License: GPL
Group:   Sciences/Physics
URL:     http://www.sat.uni-bremen.de/arts/tools.php
Source:  %{name}.tar.bz2
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
A collection of Matlab functions for interaction with ARTS-1.1.x. Contains routines for Mie scattering and absorption, generating atmospheric scenarios, reading/writing of arts XML files, plotting, etc...

%prep
%setup -q -n %{name}

%build

%install
mkdir -p $RPM_BUILD_ROOT%{_datadir}/%{name}
cp -a * $RPM_BUILD_ROOT%{_datadir}/%{name}/

%files
%defattr(-,root,root,-)
%dir %{_datadir}/%{name}
%{_datadir}/%{name}/*

%changelog
* Thu Feb 19 2004 Oliver Lemke <olemke@linux.net> 0.1.66-1ole
- new version

* Thu Feb 19 2004 Oliver Lemke <olemke@linux.net> 0.1.64-1ole
- new package

