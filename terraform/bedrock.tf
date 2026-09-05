resource "aws_bedrock_guardrail" "this" {
  name = "log_whisperer_guardrail"
  blocked_input_messaging = "Sorry, the model cannot answer that question. Not related to application logs."
  blocked_outputs_messaging = "Sorry, the model cannot answer that question. Not related to application logs."

  content_policy_config {
    filters_config {
      type = "HATE"
      input_strength = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type = "INSULTS"
      input_strength = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type = "SEXUAL"
      input_strength = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type = "VIOLENCE"
      input_strength = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type = "MISCONDUCT"
      input_strength = "HIGH"
      output_strength = "HIGH"
    }
     filters_config {
      type            = "PROMPT_ATTACK"
      input_strength   = "HIGH"
      output_strength  = "NONE"
    }
    tier_config {
        tier_name = "CLASSIC"
    }
  }

  topic_policy_config {
    topics_config {
      name = "No_Financial_Advice"
      definition = "If the user asks questions related to Financial recommendations & Legal advice, the prompt should be blocked."
      type = "DENY"
    }

    tier_config {
      tier_name = "CLASSIC"
    }
  }

  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
  }

  sensitive_information_policy_config {
    pii_entities_config {
      type = "NAME"
      action = "BLOCK"
    }
  }
}