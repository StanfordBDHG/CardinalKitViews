//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A `TextField` that automatically handles validation of input.
///
/// This text field expects a ``ValidationEngine`` object in the environment. The engine is used
/// to validate the text field input. A ``ValidationResultsView`` is used to automatically display
/// recovery suggestions for failed ``ValidationRule`` below the text field.
public struct VerifiableTextField<FieldLabel: View, FieldFooter: View>: View {
    /// The type of text field.
    public enum TextFieldType {
        /// A standard `TextField`.
        case text
        /// A `SecureField`.
        case secure
    }

    private let label: FieldLabel
    private let textFieldFooter: FieldFooter
    private let fieldType: TextFieldType

    @Binding private var text: String

    @Environment(ValidationEngine.self)
    var validationEngine

    public var body: some View {
        VStack {
            Group {
                switch fieldType {
                case .text:
                    TextField(text: $text, label: { label })
                case .secure:
                    SecureField(text: $text, label: { label })
                }
            }
                .onSubmit {
                    // the validation modifier automatically submits the text,
                    // here we just make sure that we submit it without a debounce
                    validationEngine.submit(input: text)
                }

            HStack {
                ValidationResultsView(results: validationEngine.displayedValidationResults)

                Spacer()

                textFieldFooter
            }
        }
    }


    /// Create a new verifiable text field.
    /// - Parameters:
    ///   - label: The localized text label for the text field.
    ///   - text: The binding to the stored value.
    ///   - type: An optional ``TextFieldType``.
    ///   - footer: An optional footer displayed below the text field next to the ``ValidationResultsView``.
    public init(
        _ label: LocalizedStringResource,
        text: Binding<String>,
        type: TextFieldType = .text,
        @ViewBuilder footer: () -> FieldFooter = { EmptyView() }
    ) where FieldLabel == Text {
        self.init(text: text, type: type, label: { Text(label) }, footer: footer)
    }

    /// Create a new verifiable text field.
    /// - Parameters:
    ///   - text: The binding to the stored value.
    ///   - type: An optional ``TextFieldType``.
    ///   - label: An arbitrary label for the text field.
    ///   - footer: An optional footer displayed below the text field next to the ``ValidationResultsView``
    public init(
        text: Binding<String>,
        type: TextFieldType = .text,
        @ViewBuilder label: () -> FieldLabel,
        @ViewBuilder footer: () -> FieldFooter = { EmptyView() }
    ) {
        self._text = text
        self.fieldType = type
        self.label = label()
        self.textFieldFooter = footer()
    }
}


#if DEBUG
#Preview {
    @State var text = ""

    return Form {
        VerifiableTextField(text: $text) {
            Text(verbatim: "Password Text")
        } footer: {
            Text(verbatim: "Some Hint")
                .font(.footnote)
        }
            .validate(input: text, rules: .nonEmpty)
    }
}
#endif
