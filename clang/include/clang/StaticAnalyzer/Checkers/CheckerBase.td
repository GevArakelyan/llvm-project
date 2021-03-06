//===--- CheckerBase.td - Checker TableGen classes ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file defines the TableGen core definitions for checkers
//
//===----------------------------------------------------------------------===//

/// Describes a checker or package option type. This is important for validating
/// user supplied inputs.
/// New option types can be added by modifying this enum. Note that this
/// requires changes in the TableGen emitter file ClangSACheckersEmitter.cpp.
class CmdLineOptionTypeEnum<bits<2> val> {
  bits<2> Type = val;
}
def Integer : CmdLineOptionTypeEnum<0>;
def String : CmdLineOptionTypeEnum<1>;
def Boolean : CmdLineOptionTypeEnum<2>;

class Type<CmdLineOptionTypeEnum val> {
  bits<2> Type = val.Type;
}

/// Describes an option for a checker or a package.
class CmdLineOption<CmdLineOptionTypeEnum type, string cmdFlag, string desc,
                    string defaultVal> {
  bits<2> Type = type.Type;
  string CmdFlag = cmdFlag;
  string Desc = desc;
  string DefaultVal = defaultVal;
}

/// Describes a list of package options.
class PackageOptions<list<CmdLineOption> opts> {
  list<CmdLineOption> PackageOptions = opts;
}

/// Describes a package. Every checker is a part of a package, for example,
/// 'NullDereference' is part of the 'core' package, hence it's full name is
/// 'core.NullDereference'.
/// Example:
///   def Core : Package<"core">;
class Package<string name> {
  string              PackageName = name;
  // This field is optional.
  list<CmdLineOption> PackageOptions;
  Package             ParentPackage;
  bit                 Hidden = 0;
}

/// Describes a 'super' package that holds another package inside it. This is
/// used to nest packages in one another. One may, for example, create the
/// 'builtin' package inside 'core', thus creating the package 'core.builtin'.
/// Example:
///   def CoreBuiltin : Package<"builtin">, ParentPackage<Core>;
class ParentPackage<Package P> { Package ParentPackage = P; }

/// A description. May be displayed to the user when clang is invoked with
/// a '-help'-like command line option.
class HelpText<string text> { string HelpText = text; }

/// Describes what kind of documentation exists for the checker.
class DocumentationEnum<bits<2> val> {
  bits<2> Documentation = val;
}
def NotDocumented : DocumentationEnum<0>;
def HasDocumentation : DocumentationEnum<1>;
def HasAlphaDocumentation : DocumentationEnum<2>;

class Documentation<DocumentationEnum val> {
  bits<2> Documentation = val.Documentation;
}

/// Describes a checker. Every builtin checker has to be registered with the use
/// of this class (out-of-trunk checkers loaded from plugins obviously don't).
/// Note that a checker has a name (e.g.: 'NullDereference'), and a fullname,
/// that is autogenerated with the help of the ParentPackage field, that also
/// includes package names (e.g.: 'core.NullDereference').
/// Example:
///   def DereferenceChecker : Checker<"NullDereference">,
///     HelpText<"Check for dereferences of null pointers">;
class Checker<string name = ""> {
  string              CheckerName = name;
  string              HelpText;
  // This field is optional.
  list<CmdLineOption> CheckerOptions;
  // This field is optional.
  list<Checker>       Dependencies;
  bits<2>             Documentation;
  Package             ParentPackage;
  bit                 Hidden = 0;
}

/// Describes a list of checker options.
class CheckerOptions<list<CmdLineOption> opts> {
  list<CmdLineOption> CheckerOptions = opts;
}

/// Describes dependencies in between checkers. For example, InnerPointerChecker
/// relies on information MallocBase gathers.
/// Example:
///   def InnerPointerChecker : Checker<"InnerPointer">,
///     HelpText<"Check for inner pointers of C++ containers used after "
///              "re/deallocation">,
///     Dependencies<[MallocBase]>;
class Dependencies<list<Checker> Deps = []> {
  list<Checker> Dependencies = Deps;
}

/// Marks a checker or a package hidden. Hidden entries won't be displayed in
/// -analyzer-checker-help, which is desirable for alpha or modeling checkers.
class Hidden { bit Hidden = 1; }
