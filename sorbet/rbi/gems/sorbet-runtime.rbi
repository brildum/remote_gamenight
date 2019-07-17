# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: true
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/sorbet-runtime/all/sorbet-runtime.rbi
#
# sorbet-runtime-0.4.4378
module T::Configuration
  def self.call_validation_error_handler(signature, opts); end
  def self.call_validation_error_handler=(value); end
  def self.call_validation_error_handler_default(signature, opts); end
  def self.default_checked_level=(default_checked_level); end
  def self.enable_checking_for_sigs_marked_checked_tests; end
  def self.hard_assert_handler(str, extra); end
  def self.hard_assert_handler=(value); end
  def self.hard_assert_handler_default(str, _); end
  def self.inline_type_error_handler(error); end
  def self.inline_type_error_handler=(value); end
  def self.inline_type_error_handler_default(error); end
  def self.log_info_handler(str, extra); end
  def self.log_info_handler=(value); end
  def self.log_info_handler_default(str, extra); end
  def self.scalar_types; end
  def self.scalar_types=(values); end
  def self.sig_builder_error_handler(error, location); end
  def self.sig_builder_error_handler=(value); end
  def self.sig_builder_error_handler_default(error, location); end
  def self.sig_validation_error_handler(error, opts); end
  def self.sig_validation_error_handler=(value); end
  def self.sig_validation_error_handler_default(error, opts); end
  def self.soft_assert_handler(str, extra); end
  def self.soft_assert_handler=(value); end
  def self.soft_assert_handler_default(str, extra); end
  def self.validate_lambda_given!(value); end
end
module T::Profile
  def self.reset; end
  def self.typecheck_count_estimate; end
  def self.typecheck_duration; end
  def self.typecheck_duration=(arg0); end
  def self.typecheck_duration_estimate; end
  def self.typecheck_sample_attempts; end
  def self.typecheck_sample_attempts=(arg0); end
  def self.typecheck_samples; end
  def self.typecheck_samples=(arg0); end
end
module T
end
module T::Array
end
module T::Hash
end
module T::Enumerable
end
module T::Enumerator
  def self.[](type); end
end
module T::Range
end
module T::Set
end
module T::CFGExport
end
class T::Private::DeclState
  def active_declaration; end
  def active_declaration=(arg0); end
  def reset!; end
  def self.current; end
  def self.current=(other); end
end
module T::Utils
  def self.arity(method); end
  def self.coerce(val); end
  def self.methods_excluding_object(mod); end
  def self.register_forwarder(from_method, to_method, remove_first_param: nil); end
  def self.run_all_sig_blocks; end
  def self.signature_for_instance_method(mod, method_name); end
  def self.string_truncate_middle(str, start_len, end_len, ellipsis = nil); end
  def self.unwrap_nilable(type); end
  def self.validate_sigs; end
  def self.wrap_method_with_call_validation_if_needed(mod, method_sig, original_method); end
end
class T::Utils::RuntimeProfiled
end
module T::Private::ClassUtils
  def self.replace_method(mod, name, &blk); end
  def self.visibility_method_name(mod, name); end
end
class T::Private::ClassUtils::ReplacedMethod
  def bind(obj); end
  def initialize(mod, old_method, new_method, overwritten, visibility); end
  def restore; end
  def to_s; end
end
module T::Private::ErrorHandler
  def self.handle_call_validation_error(signature, opts = nil); end
  def self.handle_inline_type_error(type_error); end
  def self.handle_sig_builder_error(error, location); end
  def self.handle_sig_validation_error(error, opts = nil); end
end
module T::Private::RuntimeLevels
  def self._toggle_checking_tests(checked); end
  def self.check_tests?; end
  def self.default_checked_level; end
  def self.default_checked_level=(default_checked_level); end
  def self.enable_checking_in_tests; end
end
module T::Private::Methods
  def self._on_method_added(hook_mod, method_name, is_singleton_method: nil); end
  def self.build_sig(hook_mod, method_name, original_method, current_declaration, loc); end
  def self.declare_sig(mod, &blk); end
  def self.finalize_proc(decl); end
  def self.has_sig_block_for_key(key); end
  def self.has_sig_block_for_method(method); end
  def self.install_hooks(mod); end
  def self.install_singleton_method_added_hook(singleton_klass); end
  def self.key_to_method(key); end
  def self.maybe_run_sig_block_for_key(key); end
  def self.maybe_run_sig_block_for_method(method); end
  def self.method_to_key(method); end
  def self.register_forwarder(from_method, to_method, mode: nil, remove_first_param: nil); end
  def self.run_all_sig_blocks; end
  def self.run_builder(declaration_block); end
  def self.run_sig(hook_mod, method_name, original_method, declaration_block); end
  def self.run_sig_block_for_key(key); end
  def self.run_sig_block_for_method(method); end
  def self.sig_error(loc, message); end
  def self.signature_for_key(key); end
  def self.signature_for_method(method); end
  def self.start_proc; end
  def self.unwrap_method(hook_mod, signature, original_method); end
end
class T::Private::Methods::DeclarationBlock < Struct
  def blk; end
  def blk=(_); end
  def loc; end
  def loc=(_); end
  def mod; end
  def mod=(_); end
  def self.[](*arg0); end
  def self.inspect; end
  def self.members; end
  def self.new(*arg0); end
end
module T::Sig
  def sig(&blk); end
end
module T::Sig::WithoutRuntime
end
module T::Helpers
  def abstract!; end
  def interface!; end
  def mixes_in_class_methods(mod); end
end
module T::Types
end
class T::Types::Base
  def self.method_added(method_name); end
end
class T::Types::TypedEnumerable < T::Types::Base
end
class T::Types::ClassOf < T::Types::Base
end
class T::Types::Enum < T::Types::Base
  def self.method_added(name); end
  def self.singleton_method_added(name); end
  extend T::Sig
end
class T::Types::FixedArray < T::Types::Base
end
class T::Types::FixedHash < T::Types::Base
end
class T::Types::Intersection < T::Types::Base
end
class T::Types::NoReturn < T::Types::Base
end
class T::Types::Proc < T::Types::Base
end
class T::Types::SelfType < T::Types::Base
end
class T::Types::Simple < T::Types::Base
end
class T::Types::TypeParameter < T::Types::Base
end
class T::Types::TypedArray < T::Types::TypedEnumerable
end
class T::Types::TypedEnumerator < T::Types::TypedEnumerable
end
class T::Types::TypedHash < T::Types::TypedEnumerable
end
class T::Types::TypedRange < T::Types::TypedEnumerable
end
class T::Types::TypedSet < T::Types::TypedEnumerable
end
class T::Types::Union < T::Types::Base
end
class T::Types::Untyped < T::Types::Base
end
class T::Private::Types::NotTyped < T::Types::Base
end
class T::Private::Types::Void < T::Types::Base
end
module T::Private::Types::Void::VOID
end
class T::Private::Types::StringHolder < T::Types::Base
end
class T::Types::TypeVariable < T::Types::Base
end
class T::Types::TypeMember < T::Types::TypeVariable
end
class T::Types::TypeTemplate < T::Types::TypeVariable
end
module T::Private::Methods::Modes
  def self.abstract; end
  def self.implementation; end
  def self.overridable; end
  def self.overridable_implementation; end
  def self.override; end
  def self.standard; end
  def self.untyped; end
end
module T::Private::Methods::CallValidation
  def self.create_validator_method(mod, original_method, method_sig, original_visibility); end
  def self.create_validator_method_fast(mod, original_method, method_sig); end
  def self.create_validator_method_fast0(mod, original_method, method_sig, return_type); end
  def self.create_validator_method_fast1(mod, original_method, method_sig, return_type, arg0_type); end
  def self.create_validator_method_fast2(mod, original_method, method_sig, return_type, arg0_type, arg1_type); end
  def self.create_validator_method_fast3(mod, original_method, method_sig, return_type, arg0_type, arg1_type, arg2_type); end
  def self.create_validator_method_fast4(mod, original_method, method_sig, return_type, arg0_type, arg1_type, arg2_type, arg3_type); end
  def self.create_validator_procedure_fast(mod, original_method, method_sig); end
  def self.create_validator_procedure_fast0(mod, original_method, method_sig); end
  def self.create_validator_procedure_fast1(mod, original_method, method_sig, arg0_type); end
  def self.create_validator_procedure_fast2(mod, original_method, method_sig, arg0_type, arg1_type); end
  def self.create_validator_procedure_fast3(mod, original_method, method_sig, arg0_type, arg1_type, arg2_type); end
  def self.create_validator_procedure_fast4(mod, original_method, method_sig, arg0_type, arg1_type, arg2_type, arg3_type); end
  def self.create_validator_slow(mod, original_method, method_sig); end
  def self.disable_fast_path; end
  def self.is_allowed_to_have_fast_path; end
  def self.report_error(method_sig, error_message, kind, name, type, value, caller_offset: nil); end
  def self.validate_call(instance, original_method, method_sig, args, blk); end
  def self.visibility_method_name(mod, name); end
  def self.wrap_method_if_needed(mod, method_sig, original_method); end
end
module T::Private::Methods::SignatureValidation
  def self.base_override_loc_str(signature, super_signature); end
  def self.method_loc_str(method); end
  def self.pretty_mode(signature); end
  def self.validate(signature); end
  def self.validate_non_override_mode(signature); end
  def self.validate_override_mode(signature, super_signature); end
  def self.validate_override_shape(signature, super_signature); end
  def self.validate_override_types(signature, super_signature); end
end
module T::AbstractUtils
  def self.abstract_method?(method); end
  def self.abstract_methods_for(mod); end
  def self.abstract_module?(mod); end
  def self.declared_abstract_methods_for(mod); end
end
module T::Private::Abstract::Validate
  def self.describe_method(method, show_owner: nil); end
  def self.validate_abstract_module(mod); end
  def self.validate_interface(mod); end
  def self.validate_interface_all_abstract(mod, method_names); end
  def self.validate_interface_all_public(mod, method_names); end
  def self.validate_subclass(mod); end
end
module T::Generic
  def [](*types); end
  def type_member(variance = nil, fixed: nil); end
  def type_template(variance = nil, fixed: nil); end
  include Kernel
  include T::Helpers
end
class T::InterfaceWrapper
  def __interface_mod_DO_NOT_USE; end
  def __target_obj_DO_NOT_USE; end
  def initialize(target_obj, interface_mod); end
  def is_a?(other); end
  def kind_of?(other); end
  def self.dynamic_cast(obj, mod); end
  def self.method_added(name); end
  def self.new(*arg0); end
  def self.self_methods; end
  def self.singleton_method_added(name); end
  def self.wrap_instance(obj, interface_mod); end
  def self.wrap_instances(*args, &blk); end
  def self.wrapped_dynamic_cast(obj, mod); end
  extend T::Sig
end
module T::InterfaceWrapper::Helpers
  def wrap_instance(obj); end
  def wrap_instances(arr); end
end
module T::Private::Abstract::Declare
  def self.declare_abstract(mod, type:); end
end
module T::Private::Abstract::Hooks
  def append_features(other); end
  def extend_object(other); end
  def inherited(other); end
  def prepended(other); end
end
module T::Private
end
module T::Private::Casts
  def self.cast(value, type, cast_method:); end
end
class T::Private::Methods::Declaration < Struct
  def bind; end
  def bind=(_); end
  def checked; end
  def checked=(_); end
  def finalized; end
  def finalized=(_); end
  def generated; end
  def generated=(_); end
  def mod; end
  def mod=(_); end
  def mode; end
  def mode=(_); end
  def on_failure; end
  def on_failure=(_); end
  def override_allow_incompatible; end
  def override_allow_incompatible=(_); end
  def params; end
  def params=(_); end
  def returns; end
  def returns=(_); end
  def self.[](*arg0); end
  def self.inspect; end
  def self.members; end
  def self.new(*arg0); end
  def type_parameters; end
  def type_parameters=(_); end
end
class T::Private::Methods::DeclBuilder
  def abstract; end
  def bind(type); end
  def check_live!; end
  def checked(level); end
  def decl; end
  def finalize!; end
  def generated; end
  def implementation; end
  def initialize(mod); end
  def on_failure(*args); end
  def overridable; end
  def override(allow_incompatible: nil); end
  def params(params); end
  def returns(type); end
  def type_parameters(*names); end
  def void; end
end
class T::Private::Methods::DeclBuilder::BuilderError < StandardError
end
class T::Private::Methods::Signature
  def arg_count; end
  def arg_types; end
  def bind; end
  def block_name; end
  def block_type; end
  def check_level; end
  def dsl_method; end
  def each_args_value_type(args); end
  def ever_failed; end
  def generated; end
  def has_keyrest; end
  def has_rest; end
  def initialize(method:, method_name:, raw_arg_types:, raw_return_type:, bind:, mode:, check_level:, on_failure:, parameters: nil, generated: nil, override_allow_incompatible: nil); end
  def keyrest_name; end
  def keyrest_type; end
  def kwarg_names; end
  def kwarg_types; end
  def mark_failed; end
  def method; end
  def method_desc; end
  def method_name; end
  def mode; end
  def on_failure; end
  def override_allow_incompatible; end
  def owner; end
  def parameters; end
  def req_arg_count; end
  def req_kwarg_names; end
  def rest_name; end
  def rest_type; end
  def return_type; end
  def self.new_untyped(method:, mode: nil, parameters: nil); end
end
module T::Utils::Nilable
  def self.get_type_info(prop_type); end
  def self.get_underlying_type(prop_type); end
  def self.get_underlying_type_object(prop_type); end
  def self.is_union_with_nilclass(prop_type); end
end
class T::Utils::Nilable::TypeInfo < Struct
  def is_union_type; end
  def is_union_type=(_); end
  def non_nilable_type; end
  def non_nilable_type=(_); end
  def self.[](*arg0); end
  def self.inspect; end
  def self.members; end
  def self.new(*arg0); end
end
module T::Private::Abstract::Data
  def self.get(mod, key); end
  def self.key?(mod, key); end
  def self.set(mod, key, value); end
  def self.set_default(mod, key, default); end
end
module T::Private::MixesInClassMethods
  def included(other); end
end
module T::Private::Mixins
  def self.declare_mixes_in_class_methods(mixin, class_methods); end
end
module T::Props
  extend T::Helpers
end
module T::Props::ClassMethods
  def const(*args, &blk); end
  def decorator; end
  def decorator_class; end
  def extended(child); end
  def included(child); end
  def inherited(child); end
  def plugin(mod); end
  def plugins; end
  def prepended(child); end
  def prop(name, cls, rules = nil); end
  def props; end
  def reload_decorator!; end
  def self.method_added(name); end
  def self.singleton_method_added(name); end
  def validate_prop_value(prop, val); end
  extend T::Helpers
  extend T::Sig
end
module T::Props::CustomType
  def deserialize(_mongo_scalar); end
  def instance?(_value); end
  def self.included(_base); end
  def self.scalar_type?(val); end
  def self.valid_serialization?(val, type = nil); end
  def serialize(_instance); end
  def valid?(value); end
  include Kernel
end
class T::Props::Decorator
  def add_prop_definition(*args, &blk); end
  def all_props(*args, &blk); end
  def array_subdoc_type(*args, &blk); end
  def check_prop_type(*args, &blk); end
  def convert_type_to_class(*args, &blk); end
  def decorated_class; end
  def define_foreign_method(*args, &blk); end
  def define_getter_and_setter(*args, &blk); end
  def foreign_prop_get(*args, &blk); end
  def get(*args, &blk); end
  def handle_foreign_hint_only_option(*args, &blk); end
  def handle_foreign_option(*args, &blk); end
  def handle_redaction_option(*args, &blk); end
  def hash_key_custom_type(*args, &blk); end
  def hash_value_subdoc_type(*args, &blk); end
  def initialize(klass); end
  def is_nilable?(*args, &blk); end
  def model_inherited(child); end
  def mutate_prop_backdoor!(*args, &blk); end
  def plugin(mod); end
  def prop_defined(*args, &blk); end
  def prop_get(*args, &blk); end
  def prop_rules(*args, &blk); end
  def prop_set(*args, &blk); end
  def prop_validate_definition!(*args, &blk); end
  def props; end
  def self.method_added(name); end
  def self.singleton_method_added(name); end
  def set(*args, &blk); end
  def shallow_clone_ok(*args, &blk); end
  def smart_coerce(*args, &blk); end
  def valid_props(*args, &blk); end
  def validate_foreign_option(*args, &blk); end
  def validate_not_missing_sensitivity(*args, &blk); end
  def validate_prop_name(name); end
  def validate_prop_value(*args, &blk); end
  extend T::Sig
end
class T::Props::Decorator::NoRulesError < StandardError
end
module T::Props::Decorator::Private
  def self.apply_class_methods(plugin, target); end
  def self.apply_decorator_methods(plugin, target); end
end
class T::Props::Error < StandardError
end
class T::Props::InvalidValueError < T::Props::Error
end
class T::Props::ImmutableProp < T::Props::Error
end
module T::Props::Plugin
  extend T::Helpers
  extend T::Props::ClassMethods
  include T::Props
end
module T::Props::Plugin::ClassMethods
  def included(child); end
end
module T::Props::Utils
  def self.deep_clone_object(what, freeze: nil); end
  def self.merge_serialized_optional_rule(prop_rules); end
  def self.need_nil_read_check?(prop_rules); end
  def self.need_nil_write_check?(prop_rules); end
  def self.optional_prop?(prop_rules); end
  def self.required_prop?(prop_rules); end
end
module T::Props::Optional
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  include T::Props::Plugin
end
module T::Props::Optional::DecoratorMethods
  def add_prop_definition(prop, rules); end
  def compute_derived_rules(rules); end
  def get_default(rules, instance_class); end
  def has_default?(rules); end
  def mutate_prop_backdoor!(prop, key, value); end
  def prop_optional?(prop); end
  def prop_validate_definition!(name, cls, rules, type); end
  def valid_props; end
end
module T::Props::WeakConstructor
  def initialize(hash = nil); end
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  include T::Props::Optional
end
module T::Props::Constructor
  def initialize(hash = nil); end
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  include T::Props::WeakConstructor
end
module T::Props::PrettyPrintable
  def inspect; end
  def pretty_inspect; end
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  include T::Props::Plugin
end
module T::Props::PrettyPrintable::DecoratorMethods
  def inspect_instance(*args, &blk); end
  def inspect_instance_components(*args, &blk); end
  def inspect_prop_value(*args, &blk); end
  def join_props_with_pretty_values(*args, &blk); end
  def self.method_added(name); end
  def self.singleton_method_added(name); end
  def valid_props(*args, &blk); end
  extend T::Sig
end
module T::Props::Serializable
  def deserialize(hash, strict = nil); end
  def recursive_stringify_keys(obj); end
  def required_prop_missing_from_deserialize(prop); end
  def required_prop_missing_from_deserialize?(prop); end
  def serialize(strict = nil); end
  def with(changed_props); end
  def with_existing_hash(changed_props, existing_hash:); end
  extend T::Props::ClassMethods
  extend T::Props::ClassMethods
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  include T::Props::Optional
  include T::Props::Plugin
  include T::Props::PrettyPrintable
end
module T::Props::Serializable::DecoratorMethods
  def add_prop_definition(prop, rules); end
  def extra_props(instance); end
  def from_hash(hash, strict = nil); end
  def get_id(instance); end
  def inspect_instance_components(instance, multiline:, indent:); end
  def prop_by_serialized_forms; end
  def prop_dont_store?(prop); end
  def prop_serialized_form(prop); end
  def prop_validate_definition!(name, cls, rules, type); end
  def required_props; end
  def serialized_form_prop(serialized_form); end
  def valid_props; end
end
module T::Props::Serializable::ClassMethods
  def from_hash!(hash); end
  def from_hash(hash, strict = nil); end
  def prop_by_serialized_forms; end
end
module T::Props::TypeValidation
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  include T::Props::Plugin
end
class T::Props::TypeValidation::UnderspecifiedType < ArgumentError
end
module T::Props::TypeValidation::DecoratorMethods
  def find_invalid_subtype(*args, &blk); end
  def prop_validate_definition!(*args, &blk); end
  def self.method_added(name); end
  def self.singleton_method_added(name); end
  def type_error_message(*args, &blk); end
  def valid_props(*args, &blk); end
  def validate_type(*args, &blk); end
  extend T::Sig
end
class T::InexactStruct
  extend T::Props::ClassMethods
  extend T::Props::ClassMethods
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Serializable::ClassMethods
  include T::Props
  include T::Props::Constructor
  include T::Props::Serializable
end
class T::Struct < T::InexactStruct
  def self.inherited(subclass); end
  extend T::Props::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Plugin::ClassMethods
  extend T::Props::Serializable::ClassMethods
end
module T::Private::Abstract
end
module T::Private::Types
end
