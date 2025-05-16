import { ChangeEvent, FormEvent } from 'react';

declare global {
  namespace JSX {
    interface IntrinsicElements {
      [elemName: string]: any;
    }
  }
}

export type InputChangeEvent = ChangeEvent<HTMLInputElement | HTMLTextAreaElement>;
export type FormSubmitEvent = FormEvent<HTMLFormElement>; 