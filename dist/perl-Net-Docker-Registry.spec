#
# spec file for package perl-Net-Docker-Registry
#
# Copyright (c) 2018 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#
%define pname Net-Docker-Registry

Name:           perl-%{pname}
Version:        0.0.0
Release:        0
Summary:        Perl library to interact with docker registry
License:        GPL-2.0-or-later
Group:          Development/Libraries/Perl
Url:            https://github.com/M0ses/Net-Docker-Registry
Source:         %{pname}-%{version}.tar.xz
#BuildRequires:  
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description

%prep
%setup -q -n %{pname}-%{version}

%build
perl Build.PL --installdirs vendor --destdir %{buildroot}
./Build

%install
./Build install

%files
%defattr(-,root,root)
%doc Changes README README.md
%{perl_vendorlib}/*
%{_mandir}/man?/*

%changelog

